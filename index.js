require('dotenv').config();
const mqtt = require('mqtt');
const { createClient } = require('@supabase/supabase-js');

const mqttBroker = process.env.MQTT_BROKER || 'test.mosquitto.org';
const environmentTopic = "sensors/esp32/environment";
const bpmTopic = "sensors/esp32/bpm";
const ecgTopic = "sensors/esp32/ecg";
const allTopics = [environmentTopic, bpmTopic, ecgTopic];

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;
const supabaseTable = "pacient";

if (!supabaseUrl || !supabaseKey) {
  console.error('ERROR: SUPABASE_URL și/sau SUPABASE_KEY lipsesc în .env');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);
console.log('Client Supabase inițializat.');

const deviceDataBuffer = {};
const BUFFER_TIMEOUT_MS = 15000;

console.log(`Conectare la MQTT broker: ${mqttBroker}`);
const client = mqtt.connect(mqttBroker, {
  clientId: `mqtt_supabase_bridge_${Math.random().toString(16).substring(2, 8)}`
});

client.on('connect', () => {
  console.log('Conectat la broker MQTT.');
  client.subscribe(allTopics, (err, granted) => {
    if (err) {
      console.error('Eroare la abonare MQTT:', err);
    } else {
      granted.forEach(grant =>
        console.log(`Subscris la: ${grant.topic} (QoS ${grant.qos})`)
      );
    }
  });
});

client.on('message', async (topic, message) => {
  const messageStr = message.toString();
  const timestamp = new Date().toISOString();
  const cnp = '1234567890124';

  if (!cnp) {
    console.warn(`Nu există pacientul cu CNP ${cnp} în Supabase.`);
    return;
  }

  console.log(`\n--- Mesaj primit (${timestamp}) ---`);
  console.log(`Topic: ${topic}`);
  console.log(`Payload: ${messageStr}`);

  let parsedData;
  try {
    parsedData = JSON.parse(messageStr);
  } catch (err) {
    console.error(`Eroare la parsarea mesajului JSON:`, err.message);
    return;
  }

  let dataToUpdate = {};

  if (topic === environmentTopic) {
    if (parsedData.temperature !== undefined && parsedData.humidity !== undefined) {
      dataToUpdate.temperatura = parsedData.temperature;
      dataToUpdate.umiditate = parsedData.humidity;
    }
  } else if (topic === bpmTopic) {
    if (parsedData.bpm_avg !== undefined) {
      dataToUpdate.puls = parsedData.bpm_avg;
    }
  } else if (topic === ecgTopic) {
    if (parsedData.ecg_data !== undefined) {
      dataToUpdate.ecg = parsedData.ecg_data.toString();
    }
  } else {
    console.warn(`Topic necunoscut: ${topic}`);
    return;
  }

  if (Object.keys(dataToUpdate).length > 0) {
    await updatePacientByCnp(cnp, dataToUpdate);
  }
});

async function updatePacientByCnp(cnp, updateData) {
  console.log(`Actualizare pacient cu CNP ${cnp}:`, updateData);
  try {
    const { error } = await supabase
      .from(supabaseTable)
      .update(updateData)
      .eq('cnp', cnp);

    if (error) {
      console.error('Eroare la UPDATE în Supabase:', error.message);
    } else {
      //console.log('UPDATE în Supabase reușit.');
    }
  } catch (err) {
    console.error('Eroare în timpul actualizării Supabase:', err);
  }
}

client.on('error', err => console.error('Eroare MQTT:', err));
client.on('offline', () => console.warn('MQTT este offline.'));
client.on('reconnect', () => console.log('Reconectare MQTT...'));

process.on('SIGINT', () => {
  console.log('\nÎnchidere aplicație...');
  client.end(true, () => {
    console.log('Conexiune MQTT închisă. La revedere!');
    process.exit(0);
  });
});
