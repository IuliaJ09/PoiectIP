#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <Wire.h>
#include "DHT.h"
#include "MAX30105.h"
#include "heartRate.h"

const char* ssid = "LinksysB019";
const char* password = "wm83y3fby4";

const char* mqtt_server = "test.mosquitto.org";
const int   mqtt_port = 1883;
const char* mqtt_client_id = "esp32-multi-sensor-01";

const char* environment_topic = "sensors/esp32/environment";
const char* bpm_topic = "sensors/esp32/bpm";
const char* ecg_topic = "sensors/esp32/ecg";

#define DHTPIN 26
const int ecgPin = 36;
const int loMinus = 39;
const int loPlus = 34;

#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);
MAX30105 particleSensor;

WiFiClient espClient;
PubSubClient client(espClient);

struct DhtReading {
  float temperature = NAN;
  float humidity = NAN;
  bool success = false;
};

void connectWifi();
void reconnectMqtt();
DhtReading readDhtSensor();
void updateBPMCalculation();
void publishBPMData();
int readEcgSensor();
void collectAndPublishEcgData();

void setup() {
    Serial.begin(9600);
    while (!Serial && millis() < 2000);
    Serial.println("\nBooting...");

    connectWifi();

    client.setServer(mqtt_server, mqtt_port);

    Serial.println(F("DHT sensor setup start..."));
    dht.begin();
    Serial.println(F("DHT sensor setup done."));

    pinMode(loPlus, INPUT);
    pinMode(loMinus, INPUT);
    Serial.println(F("ECG Pins configured."));

    Serial.println("Initializing MAX30105...");
    if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) {
        Serial.println("MAX30105 was not found. Please check wiring/power.");
        while (1);
    }
    Serial.println("MAX30105 Found!");

    byte ledBrightness = 60;
    byte sampleAverage = 4;
    byte ledMode = 2;
    int sampleRate = 100;
    int pulseWidth = 411;
    int adcRange = 4096;
    particleSensor.setup(ledBrightness, sampleAverage, ledMode, sampleRate, pulseWidth, adcRange);
    Serial.println("MAX30105 Configured.");

    Serial.println("Setup complete. Starting main loop.");
}

static unsigned long lastDhtSampleTime  = 0;
static unsigned long lastDhtPublishTime = 0;

const unsigned long DHT_SAMPLE_INTERVAL  = 5000;
const unsigned long DHT_PUBLISH_INTERVAL = 60000;

static float tempSum   = 0.0;
static float humSum    = 0.0;
static int sampleCount = 0;

void loop() {
    if (!client.connected()) {
        reconnectMqtt();
    }
    client.loop();

    updateBPMCalculation();
    collectAndPublishEcgData();

    unsigned long currentMillis = millis();

    if (currentMillis - lastDhtSampleTime >= DHT_SAMPLE_INTERVAL) {
        lastDhtSampleTime = currentMillis;

        DhtReading reading = readDhtSensor();

        if (reading.success) {
            tempSum += reading.temperature;
            humSum += reading.humidity;
            sampleCount++;

            Serial.print("[5s] DHT read: T = ");Serial.print(reading.temperature);Serial.print(" °C, H = ");Serial.print(reading.humidity);Serial.println(" %");
        } else {
            Serial.println("[5s] Failed DHT read, skipping this sample.");
        }
    }

    if (currentMillis - lastDhtPublishTime >= DHT_PUBLISH_INTERVAL) {
        lastDhtPublishTime = currentMillis;

        if (sampleCount > 0) {
            float avgTemp = tempSum / sampleCount;
            float avgHum  = humSum  / sampleCount;

            StaticJsonDocument<128> jsonDoc;
            jsonDoc["temperature"] = avgTemp;
            jsonDoc["humidity"]    = avgHum;

            char jsonBuffer[128];
            serializeJson(jsonDoc, jsonBuffer);

            Serial.println();Serial.print("Publishing ENV to topic '");Serial.print(environment_topic);Serial.print("': ");Serial.println(jsonBuffer);

            if (client.publish(environment_topic, jsonBuffer)) {
              //Serial.println(F("Published successfully."));
            }else{
                Serial.println("Failed!");
            }
        } else {
            Serial.println("No valid DHT samples in the last minute, skipping publish.");
        }

        tempSum     = 0.0;
        humSum      = 0.0;
        sampleCount = 0;
        Serial.println();
    }
    publishBPMData();
}

void connectWifi() {
    delay(10);
    Serial.println();
    Serial.print("Connecting to WiFi: ");
    Serial.println(ssid);
    WiFi.mode(WIFI_STA);
    WiFi.disconnect();
    delay(100);
    WiFi.begin(ssid, password);
    WiFi.setSleep(false);

    int wifi_retries = 0;
    Serial.print("Status: ");
    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.print(".");
        Serial.print(WiFi.status());
        wifi_retries++;
        if (wifi_retries > 25) {
            Serial.println("\nWiFi connection timed out. Restarting...");
            ESP.restart();
        }
    }
    Serial.println("\nWiFi connected.");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
}

void reconnectMqtt() {
    while (!client.connected()) {
        Serial.print("Attempting MQTT connection to ");
        Serial.print(mqtt_server);
        Serial.print(" ");
        if (client.connect(mqtt_client_id)) {
            Serial.println("Connected.");
        } else {
            Serial.print("Failed, rc=");
            Serial.print(client.state());
            Serial.println(" ,try again in 5 seconds.");
            delay(5000);
        }
    }
}

DhtReading readDhtSensor() {
  DhtReading result;
  result.humidity = dht.readHumidity();
  result.temperature = dht.readTemperature();
  if (isnan(result.humidity) || isnan(result.temperature)) {
    result.success = false;
  } else {
    result.success = true;
  }
  return result;
}

#define SAMPLE_INTERVAL_BPM 5000
#define AVERAGE_INTERVAL_BPM 60000

unsigned long lastBeat = 0;
float avg5SecBPM = 0;
float minuteAvgBPM = 0;

void updateBPMCalculation() {
    static unsigned long last5SecTime = 0;
    static unsigned long lastMinTime = 0;

    static float bpmSum = 0;
    static int bpmCount = 0;

    static float bpmBuffer[12];
    static int bpmBufferIndex = 0;
    
    unsigned long now = millis();
    
    long irValue = particleSensor.getIR();

    if (irValue < 50000) {
        bpmSum = 0;
        bpmCount = 0;
        bpmBufferIndex = 0;
        for (int i = 0; i < 12; i++) {
            bpmBuffer[i] = 0;
        }
        return;
    }
    
    if (checkForBeat(irValue)) {
        unsigned long nowBeat = millis();
        unsigned long delta = nowBeat - lastBeat;
        lastBeat = nowBeat;
        
        float currentBPM = 60000.0 / delta;

        if (currentBPM >= 20 && currentBPM < 255) {
            bpmSum += currentBPM; 
            bpmCount++;
            Serial.print("Detected beat, Instant BPM = ");
            Serial.println(currentBPM);
        }
    }
    
    if (now - last5SecTime >= SAMPLE_INTERVAL_BPM) {
        last5SecTime = now;
        
        if (bpmCount > 0)
            avg5SecBPM = bpmSum / bpmCount;
        else
            avg5SecBPM = 0;
        
        if (bpmBufferIndex < 12) {
            bpmBuffer[bpmBufferIndex++] = avg5SecBPM;
        }
        
        Serial.print("[5 sec sample] Average BPM: ");
        Serial.println(avg5SecBPM);
        
        bpmSum = 0;
        bpmCount = 0;
    }
    
    if (now - lastMinTime >= AVERAGE_INTERVAL_BPM) {
        lastMinTime = now;
        if (bpmBufferIndex > 0) {
            float sum = 0;
            for (int i = 0; i < bpmBufferIndex; i++) {
                sum += bpmBuffer[i];
            }
            float minuteAvgBPM = sum / bpmBufferIndex;
            Serial.print("Average BPM over the minute: ");
            Serial.println(minuteAvgBPM);
        } else {
            Serial.println("No BPM samples collected in the last minute.");
        }
        
        bpmBufferIndex = 0;
    }
}

unsigned long lastBpmPublish = 0;
const unsigned long BPM_PUBLISH_INTERVAL = 60000;

void publishBPMData() {
    unsigned long now = millis();
    if (now - lastBpmPublish >= BPM_PUBLISH_INTERVAL){
        lastBpmPublish = now;

        StaticJsonDocument<64> bpmJson;
        bpmJson["bpm_avg"] = avg5SecBPM;
        
        char bpmBuffer[64];
        serializeJson(bpmJson, bpmBuffer);

        Serial.print("Publishing BPM to topic '"); Serial.print(bpm_topic); Serial.print("': "); Serial.println(bpmBuffer);

        if (client.publish(bpm_topic, bpmBuffer)) {
            //Serial.println("Published successfully.");
        } else {
            Serial.println("Failed!");
        }
        Serial.println();
    }
}

const int ECG_BUFFER_SIZE = 100;
int ecgBuffer[ECG_BUFFER_SIZE];
int ecgBufferIndex = 0;

enum EcgState { IDLE, RECORDING };
static EcgState ecgState = IDLE;

unsigned long lastCycleStart = 0;
unsigned long recordStart = 0;
unsigned long lastEcgSampleTime = 0;
unsigned long lastEcgPublish = 0;

const unsigned long RECORD_DURATION = 11000;
const unsigned long CYCLE_INTERVAL = 20000;
const unsigned long ECG_SAMPLE_INTERVAL = 1000;
const unsigned long ECG_PUBLISH_INTERVAL = 60000;

int setsRecorded = 0;

int readEcgSensor() {
    return analogRead(ecgPin);
}

void collectAndPublishEcgData() {
    unsigned long now = millis();

    switch (ecgState) {
        case IDLE:
            if (now - lastCycleStart >= CYCLE_INTERVAL && setsRecorded < 2) {
                ecgState = RECORDING;
                recordStart = now;
                lastEcgSampleTime = now;
                Serial.print(F("START RECORDING ECG SET "));
                Serial.print(setsRecorded + 1);
                Serial.println(F(" (10s)"));
            }
            break;

        case RECORDING:
            if ((now - lastEcgSampleTime >= ECG_SAMPLE_INTERVAL) && (ecgBufferIndex < ECG_BUFFER_SIZE - 1)) {
                lastEcgSampleTime = now;
                int ecgVal = readEcgSensor();
                ecgBuffer[ecgBufferIndex++] = ecgVal;
                Serial.print(F("ECG["));
                Serial.print(ecgBufferIndex - 1);
                Serial.print(F("] = "));
                Serial.println(ecgVal);
            }

            if ((now - recordStart >= RECORD_DURATION) || (ecgBufferIndex >= ECG_BUFFER_SIZE - 1)) {
                Serial.print(F("END RECORDING ECG SET "));
                Serial.print(setsRecorded + 1);
                Serial.print(F(" ("));
                Serial.print(ecgBufferIndex);
                Serial.println(F(" total samples so far)"));

                setsRecorded++;
                ecgState = IDLE;
                lastCycleStart = now;

                if (setsRecorded < 2 && ecgBufferIndex < ECG_BUFFER_SIZE - 1) {
                    ecgBuffer[ecgBufferIndex++] = 0;
                    Serial.println(F("Inserted separator (0) in ECG buffer."));
                }
            }
            break;
    }

    if (now - lastEcgPublish >= ECG_PUBLISH_INTERVAL && setsRecorded == 2) {
        lastEcgPublish = now;

        StaticJsonDocument<8192> jsonDoc;
        JsonArray ecgArray = jsonDoc.createNestedArray("ecg_data");

        for (int i = 0; i < ecgBufferIndex; i++) {
            ecgArray.add(ecgBuffer[i]);
        }

        char payload[1024];
        size_t n = serializeJson(jsonDoc, payload);

        Serial.println();Serial.print(F("Publishing ECG full buffer ("));Serial.print(n);Serial.println(F(" bytes)..."));

        if (client.publish(ecg_topic, (uint8_t*)payload, n, false)) {
            //Serial.println(F("Published successfully."));
        } else {
            Serial.println(F("Failed!"));
        }

        ecgBufferIndex = 0;
        setsRecorded = 0;
        lastCycleStart = now;
        Serial.println();
    }
}