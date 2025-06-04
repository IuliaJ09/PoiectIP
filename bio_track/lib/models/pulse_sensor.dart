import 'sensor.dart';

class PulseSensor extends Sensor {
  PulseSensor({required super.sensorName, required super.sensorValue});

  @override
  String displayValueMessage() => "Pulse: ${sensorValue.toInt()} BPM";
}
