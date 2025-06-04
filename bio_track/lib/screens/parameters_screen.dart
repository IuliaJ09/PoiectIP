import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class ParametersScreen extends StatefulWidget {
  final String cnp;
  ParametersScreen({required this.cnp});

  @override
  State<ParametersScreen> createState() => _ParametersScreenState();
}

class _ParametersScreenState extends State<ParametersScreen> {
  String? ecg;
  List<int>? ecgValues;
  double? temperatura;
  double? humidity;
  int? puls;
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchSensorData();
  }

  Future<void> fetchSensorData() async {
    try {
      final data = await Supabase.instance.client
          .from('pacient')
          .select('ecg, temperatura, puls, umiditate')
          .eq('cnp', int.parse(widget.cnp))
          .maybeSingle();

      if (data != null) {
        setState(() {
          ecg = data['ecg'] ?? '';
          ecgValues = ecg
              ?.split(',')
              .map((e) => int.tryParse(e.trim()) ?? 0)
              .toList();
          temperatura = data['temperatura']?.toDouble();
          puls = data['puls']?.toInt();
          humidity = data['umiditate']?.toDouble();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Datele nu au fost găsite.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Eroare la preluarea datelor: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) return Center(child: Text(error));

    return RefreshIndicator(
      onRefresh: fetchSensorData,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          buildSensorCard("TempSensor", "Temperatura: ${temperatura?.toStringAsFixed(1)} °C"),
          buildSensorCard("HumiditySensor", "Umiditatea: ${humidity?.toStringAsFixed(1)}"),
          buildSensorCard("PulseSensor", "Puls: ${puls ?? '-'} BPM"),
          buildSensorCard("EKGSensor", "Valori EKG: ${ecgValues != null && ecgValues!.isNotEmpty ? ecgValues!.length : 0} puncte"),
          if (ecgValues != null && ecgValues!.length > 1)
            SizedBox(
              height: 250,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: ecgValues!.length * 5,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: ecgValues!.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble())).toList(),
                          isCurved: false,
                          color: Colors.teal,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSensorCard(String name, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(name),
        subtitle: Text(value),
        leading: Icon(Icons.monitor_heart),
      ),
    );
  }
}
