import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlertsScreen extends StatefulWidget {
  final String cnp;
  AlertsScreen({required this.cnp});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<Map<String, dynamic>> alerts = [];
  bool isLoading = true;
  String error = '';
  String selectedFilter = 'Toate';

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final data = await Supabase.instance.client
          .from('alerte')
          .select()
          .eq('cnp', int.parse(widget.cnp))
          .order('data_alerta', ascending: false);

      setState(() {
        alerts = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Eroare la încărcarea alertelor: $e';
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredAlerts {
    if (selectedFilter == 'Toate') return alerts;
    return alerts.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) return Center(child: Text(error));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: DropdownButton<String>(
            value: selectedFilter,
            onChanged: (val) {
              setState(() => selectedFilter = val!);
            },
            items: ['Toate', 'Ultimele 5']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: fetchAlerts,
            child: ListView.builder(
              itemCount: filteredAlerts.length,
              itemBuilder: (context, index) {
                final alert = filteredAlerts[index];
                return Card(
                  color: Colors.pink.shade50,
                  child: ListTile(
                    leading: Icon(Icons.warning, color: Colors.red),
                    title: Text(alert['mesaj']),
                    subtitle: Text('Data: ${alert['data_alerta']}'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
