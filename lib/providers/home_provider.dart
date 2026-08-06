import 'package:flutter/material.dart';


class SurveyItem {
  final String title;
  final String subtitle;
  final String uviScore;
  final String time;

  SurveyItem({
    required this.title,
    required this.subtitle,
    required this.uviScore,
    required this.time,
  });
}

/// [HomeProvider] mengelola data utama untuk dashboard (HomeScreen).
/// State yang dikelola meliputi:
/// - Data poin grafik historis (chartData)
/// - Skor summary harian (Safety, Beauty, Comfort)
/// - Daftar survei terbaru
class HomeProvider with ChangeNotifier {
  // Chart Data: [Mon, Tue, Wed, Thu, Fri] -> [60, 80, 20, 60, 110]
  final List<double> chartData = [60.0, 80.0, 20.0, 60.0, 110.0];

  // Summary Scores
  final int totalSurvei = 128;
  final String rataRataUvi = "7.32";

  final String safetyScore = "7.68";
  final String beautyScore = "7.20";
  final String comfortScore = "7.45";

  // Survey List
  final List<SurveyItem> recentSurveys = [
    SurveyItem(
      title: "Jl. Ijen",
      subtitle: "Klojen, Malang",
      uviScore: "UVI 814",
      time: "09:24",
    ),
    SurveyItem(
      title: "Jl. Ijen",
      subtitle: "Klojen, Malang",
      uviScore: "UVI 814",
      time: "09:24",
    ),
    SurveyItem(
      title: "Jl. Ijen",
      subtitle: "Klojen, Malang",
      uviScore: "UVI 814",
      time: "09:24",
    ),
  ];
}
