class CalendarEvent {
  final String title;
  final DateTime date;
  final String description;

  CalendarEvent({
    required this.title,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date.toIso8601String(),
        'description': description,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      title: json['title'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }
}
