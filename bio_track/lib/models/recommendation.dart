class RecommendationTest {
  final String recommendationMessage;

  RecommendationTest({required this.recommendationMessage});
}

class Recommendation {
  final String tip;
  final String continut;
  final DateTime dataEmitere;

  Recommendation({
    required this.tip,
    required this.continut,
    required this.dataEmitere,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      tip: json['tip'],
      continut: json['continut'],
      dataEmitere: DateTime.parse(json['data_emitere']),
    );
  }
}
