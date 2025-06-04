import 'calendar_event.dart';

class Calendar {
  final List<CalendarEvent> events = [];

  void addEvent(CalendarEvent event) {
    events.add(event);
  }

  List<CalendarEvent> getEventsForDate(DateTime date) {
    return events.where((event) => event.date.day == date.day && event.date.month == date.month).toList();
  }
}
