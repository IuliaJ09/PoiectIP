import 'package:shared_preferences/shared_preferences.dart';

class EventService {
  final String _eventKey = 'calendar_events';

  Future<void> addEvent(String event) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> events = prefs.getStringList(_eventKey) ?? [];
    events.add(event);
    await prefs.setStringList(_eventKey, events);
  }

  Future<List<String>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_eventKey) ?? [];
  }

  Future<void> deleteEvent(String event) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> events = prefs.getStringList(_eventKey) ?? [];
    events.remove(event);
    await prefs.setStringList(_eventKey, events);
  }
}
