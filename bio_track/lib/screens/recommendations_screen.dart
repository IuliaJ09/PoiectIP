import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recommendation.dart';

class RecommendationScreen extends StatefulWidget {
  final String cnp;

  RecommendationScreen({required this.cnp});

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  List<Recommendation> recommendations = [];
  bool isLoading = true;
  String error = '';
  String selectedFilter = 'Toate';

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    try {
      final data = await Supabase.instance.client
          .from('recomandari_medici') // tabela corectă
          .select()
          .eq('cnp', int.parse(widget.cnp))
          .order('data_emitere', ascending: false);

      final fetched = (data as List)
          .map((e) => Recommendation.fromJson(e))
          .toList();

      setState(() {
        recommendations = fetched;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Eroare la încărcarea recomandărilor: $e';
        isLoading = false;
      });
    }
  }

  List<Recommendation> get filteredRecommendations {
    if (selectedFilter == 'Toate') return recommendations;
    return recommendations.take(5).toList(); // ultimele 5, deja sortate desc
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
            onChanged: (val) => setState(() => selectedFilter = val!),
            items: ['Toate', 'Ultimele 5']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: fetchRecommendations,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredRecommendations.length,
              itemBuilder: (context, index) {
                final rec = filteredRecommendations[index];
                return Card(
                  color: Colors.green.shade50,
                  child: ListTile(
                    leading: Icon(Icons.thumb_up, color: Colors.green),
                    title: Text(rec.tip),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rec.continut),
                        Text('Data: ${rec.dataEmitere.toString()}'),
                      ],
                    ),
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
