import 'sensor.dart';

class HumiditySensor extends Sensor {
  HumiditySensor({required super.sensorName, required super.sensorValue});

  @override
  String displayValueMessage() => "Humidity: ${sensorValue.toStringAsFixed(1)}";
}
