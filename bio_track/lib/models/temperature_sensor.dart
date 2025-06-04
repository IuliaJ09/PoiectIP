import 'sensor.dart';

class TemperatureSensor extends Sensor {
  TemperatureSensor({required super.sensorName, required super.sensorValue});

  @override
  String displayValueMessage() => "Temperature: ${sensorValue.toStringAsFixed(1)} °C";
}
