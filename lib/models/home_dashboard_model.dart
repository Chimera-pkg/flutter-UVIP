class AverageScoresModel {
  final num? safetyScore;
  final num? beautyScore;
  final num? comfortScore;
  final num? uviScore;

  AverageScoresModel({
    this.safetyScore,
    this.beautyScore,
    this.comfortScore,
    this.uviScore,
  });

  factory AverageScoresModel.fromJson(Map<String, dynamic> json) {
    return AverageScoresModel(
      safetyScore: json['safety_score'],
      beautyScore: json['beauty_score'],
      comfortScore: json['comfort_score'],
      uviScore: json['uvi_score'],
    );
  }
}

class HomeDashboardModel {
  final String status;
  final int totalProjects;
  final AverageScoresModel? averageScores;

  HomeDashboardModel({
    required this.status,
    required this.totalProjects,
    this.averageScores,
  });

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    return HomeDashboardModel(
      status: json['status'] ?? '',
      totalProjects: json['total_projects'] ?? 0,
      averageScores: json['average_scores'] != null
          ? AverageScoresModel.fromJson(json['average_scores'])
          : null,
    );
  }
}
