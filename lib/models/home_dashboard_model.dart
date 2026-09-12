import 'dart:convert';

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

  factory AverageScoresModel.fromJson(dynamic rawData) {
    if (rawData == null) return AverageScoresModel();

    Map<String, dynamic> json;
    if (rawData is String) {
      try {
        json = Map<String, dynamic>.from(jsonDecode(rawData) as Map);
      } catch (_) {
        return AverageScoresModel();
      }
    } else if (rawData is Map) {
      json = Map<String, dynamic>.from(rawData);
    } else {
      return AverageScoresModel();
    }

    return AverageScoresModel(
      safetyScore: _parseNum(
        json['safety_score'] ??
            json['safety'] ??
            json['Safety'] ??
            json['safetyScore'] ??
            json['Safety_Score'],
      ),
      beautyScore: _parseNum(
        json['beauty_score'] ??
            json['beauty'] ??
            json['Beauty'] ??
            json['beautyScore'] ??
            json['Beauty_Score'],
      ),
      comfortScore: _parseNum(
        json['comfort_score'] ??
            json['comfort'] ??
            json['Comfort'] ??
            json['comfortScore'] ??
            json['Comfort_Score'],
      ),
      uviScore: _parseNum(
        json['uvi_score'] ??
            json['uvi'] ??
            json['UVI'] ??
            json['Uvi'] ??
            json['uviScore'] ??
            json['Uvi_Score'],
      ),
    );
  }

  static num? _parseNum(dynamic val) {
    if (val == null) return null;
    if (val is num) return val;
    if (val is String) return num.tryParse(val);
    return null;
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

  factory HomeDashboardModel.fromJson(dynamic rawData) {
    if (rawData == null) {
      return HomeDashboardModel(status: '', totalProjects: 0);
    }

    Map<String, dynamic> json;
    if (rawData is String) {
      try {
        json = Map<String, dynamic>.from(jsonDecode(rawData) as Map);
      } catch (_) {
        return HomeDashboardModel(status: 'error', totalProjects: 0);
      }
    } else if (rawData is Map) {
      json = Map<String, dynamic>.from(rawData);
    } else {
      return HomeDashboardModel(status: '', totalProjects: 0);
    }

    // Check if the payload is wrapped inside 'data'
    Map<String, dynamic> targetJson = json;
    if (json.containsKey('data') && json['data'] is Map) {
      targetJson = Map<String, dynamic>.from(json['data'] as Map);
    }

    final rawScores = targetJson['average_scores'] ??
        targetJson['averageScores'] ??
        targetJson['scores'] ??
        json['average_scores'] ??
        json['averageScores'];

    final rawTotal = targetJson['total_projects'] ??
        targetJson['totalProjects'] ??
        targetJson['total_surveys'] ??
        targetJson['total_survei'] ??
        targetJson['totalSurvei'] ??
        targetJson['total_data'] ??
        targetJson['total'] ??
        targetJson['count'] ??
        json['total_projects'] ??
        json['totalProjects'];

    return HomeDashboardModel(
      status: targetJson['status']?.toString() ??
          json['status']?.toString() ??
          '',
      totalProjects: _parseInt(rawTotal),
      averageScores: rawScores != null
          ? AverageScoresModel.fromJson(rawScores)
          : null,
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) {
      return int.tryParse(val) ?? (double.tryParse(val)?.toInt() ?? 0);
    }
    return 0;
  }
}
