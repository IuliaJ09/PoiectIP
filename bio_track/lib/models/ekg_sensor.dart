import 'sensor.dart';

class EKGSensor extends Sensor {
  EKGSensor({required super.sensorName, required super.sensorValue});

  @override
  String displayValueMessage() => "EKG Value: ${sensorValue.toStringAsFixed(2)}";
}
