import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackScreen extends StatefulWidget {
  final String cnp;
  const FeedbackScreen({required this.cnp});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  String selectedType = 'observatie';
  String error = '';
  bool isSending = false;

  Future<void> sendFeedback() async {
    final mesaj = _controller.text.trim();
    if (mesaj.isEmpty) {
      setState(() => error = 'Mesajul nu poate fi gol');
      return;
    }

    setState(() {
      error = '';
      isSending = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('feedback_pacient')
          .select('id_feedback')
          .order('id_feedback', ascending: false)
          .limit(1)
          .maybeSingle();

      final nextId = (response?['id_feedback'] ?? 0) + 1;

      await Supabase.instance.client.from('feedback_pacient').insert({
        'id_feedback': nextId,
        'cnp': int.parse(widget.cnp),
        'tip': selectedType,
        'mesaj': mesaj,
        'data_trimitere': DateTime.now().toIso8601String(),
      });

      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Feedback trimis.')));
    } catch (e) {
      setState(() => error = 'Eroare la trimitere: $e');
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trimite Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tip Feedback:'),
            DropdownButton<String>(
              value: selectedType,
              items: ['observatie', 'simptom', 'alarma'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => selectedType = value!),
            ),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Mesaj',
                border: OutlineInputBorder(),
              ),
            ),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error, style: TextStyle(color: Colors.red)),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isSending ? null : sendFeedback,
              child: isSending ? CircularProgressIndicator() : Text('Trimite'),
            ),
          ],
        ),
      ),
    );
  }
}
