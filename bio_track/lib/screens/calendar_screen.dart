import 'package:flutter/material.dart';
import '../models/calendar.dart';
import '../models/calendar_event.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  final String cnp;
  CalendarScreen({required this.cnp});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final Calendar calendar = Calendar();
  DateTime selectedDate = DateTime.now();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents(widget.cnp);
  }

  Future<void> _saveEvents(String cnp) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = calendar.events.map((e) => e.toJson()).toList();
    prefs.setString('calendar_events_$cnp', jsonEncode(encoded));
  }

  Future<void> _loadEvents(String cnp) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('calendar_events_$cnp');
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      calendar.events.clear();
      calendar.events.addAll(decoded.map((e) => CalendarEvent.fromJson(e)));
      setState(() {});
    }
  }

  void _addEvent() {
    if (_titleController.text.isEmpty) return;

    calendar.addEvent(CalendarEvent(
      title: _titleController.text,
      description: _descriptionController.text,
      date: selectedDate,
    ));

    _titleController.clear();
    _descriptionController.clear();

    _saveEvents(widget.cnp);
    setState(() {});
  }

  void _deleteEvent(CalendarEvent event) {
    setState(() {
      calendar.events.remove(event);
      _saveEvents(widget.cnp);
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = calendar.getEventsForDate(selectedDate);

    return Scaffold(
      appBar: AppBar(title: Text('Calendar Personal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Data selectată: ${selectedDate.toLocal().toString().split(' ')[0]}"),
            ElevatedButton(
              child: Text('Selectează dată'),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Titlu eveniment'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descriere'),
            ),
            ElevatedButton(
              onPressed: _addEvent,
              child: Text('Adaugă Eveniment'),
            ),
            Divider(),
            Text('Evenimente pentru ziua selectată:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...events.map((e) => ListTile(
              title: Text(e.title),
              subtitle: Text(e.description),
              leading: Icon(Icons.event),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEvent(e),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
