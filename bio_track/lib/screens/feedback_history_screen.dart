import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackHistoryScreen extends StatefulWidget {
  final String cnp;
  FeedbackHistoryScreen({required this.cnp});

  @override
  _FeedbackHistoryScreenState createState() => _FeedbackHistoryScreenState();
}

class _FeedbackHistoryScreenState extends State<FeedbackHistoryScreen> {
  List<Map<String, dynamic>> feedbacks = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }

  Future<void> fetchFeedbacks() async {
    try {
      final data = await Supabase.instance.client
          .from('feedback_pacient')
          .select('tip, mesaj, data_trimitere')
          .eq('cnp', int.parse(widget.cnp))
          .order('data_trimitere', ascending: false);

      setState(() {
        feedbacks = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Eroare la preluarea feedbackurilor: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) return Center(child: Text(error));

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: feedbacks.length,
      itemBuilder: (context, index) {
        final feedback = feedbacks[index];
        return Card(
          child: ListTile(
            title: Text("Tip: ${feedback['tip']}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mesaj: ${feedback['mesaj']}"),
                SizedBox(height: 4),
                Text("Trimis la: ${feedback['data_trimitere'].toString().split('.')[0]}"),
              ],
            ),
            leading: Icon(Icons.feedback),
          ),
        );
      },
    );
  }
}
