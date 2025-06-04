import 'package:flutter/material.dart';
import '../models/temperature_sensor.dart';
import '../models/pulse_sensor.dart';
import '../models/ekg_sensor.dart';

class ParametersScreenTest extends StatelessWidget {
  final sensors = [
    TemperatureSensor(sensorName: "TempSensor", sensorValue: 37.5),
    PulseSensor(sensorName: "PulseSensor", sensorValue: 72),
    EKGSensor(sensorName: "EKGSensor", sensorValue: 0.87),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sensors.length,
      itemBuilder: (context, index) {
        final sensor = sensors[index];
        return Card(
          child: ListTile(
            title: Text(sensor.sensorName),
            subtitle: Text(sensor.displayValueMessage()),
            leading: Icon(Icons.monitor_heart),
          ),
        );
      },
    );
  }
}
