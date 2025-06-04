import 'package:flutter/material.dart';
import '../models/alert.dart';

class AlertsScreenTest extends StatelessWidget {
  final List<AlertTest> alerts = [
    AlertTest(alertMessage: "Temperatură ridicată!"),
    AlertTest(alertMessage: "Puls scăzut."),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Card(
          child: ListTile(
            leading: Icon(Icons.warning, color: Colors.red),
            title: Text(alert.alertMessage),
          ),
        );
      },
    );
  }
}
