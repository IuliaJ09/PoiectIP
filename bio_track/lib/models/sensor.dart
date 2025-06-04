abstract class Sensor {
  final String sensorName;
  final double sensorValue;

  Sensor({required this.sensorName, required this.sensorValue});

  String displayValueMessage();
}
