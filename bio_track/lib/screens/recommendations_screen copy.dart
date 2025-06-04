import 'package:flutter/material.dart';
import '../models/recommendation.dart';

class RecommendationsScreenTest extends StatelessWidget {
  final List<RecommendationTest> recommendations = [
    RecommendationTest(recommendationMessage: "Bea apă și odihnește-te."),
    RecommendationTest(recommendationMessage: "Consultă un medic dacă simptomele persistă."),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final reco = recommendations[index];
        return Card(
          child: ListTile(
            leading: Icon(Icons.health_and_safety, color: Colors.green),
            title: Text(reco.recommendationMessage),
          ),
        );
      },
    );
  }
}
