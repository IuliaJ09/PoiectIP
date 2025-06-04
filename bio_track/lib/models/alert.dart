class AlertTest {
  final String alertMessage;

  AlertTest({required this.alertMessage});
}

class Alert {
  final String alertMessage;
  final DateTime alertDate;

  Alert({required this.alertMessage, required this.alertDate});

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      alertMessage: json['mesaj'],
      alertDate: DateTime.parse(json['data_alerta']),
    );
  }
}
