import 'package:flutter/material.dart';
import 'package:uvip/providers/project_provider.dart';
import 'package:uvip/models/project_model.dart';

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

  // Dynamic data from ProjectProvider
  late final ProjectProvider _projectProvider;

  void setProjectProvider(ProjectProvider projectProvider) {
    _projectProvider = projectProvider;
    notifyListeners();
  }

  // Summary Scores - Dynamic from projects
  int get totalSurvei => _projectProvider.projects.length;

  String get rataRataUvi {
    final avg = _projectProvider.getAverageUVI();
    return avg.toStringAsFixed(2);
  }

  String get safetyScore {
    if (_projectProvider.projects.isEmpty) return "0.00";
    final scores = _projectProvider.projects
        .where((p) => p.safetyScore != null)
        .map((p) => p.safetyScore!)
        .toList();
    if (scores.isEmpty) return "0.00";
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    return avg.toStringAsFixed(2);
  }

  String get beautyScore {
    if (_projectProvider.projects.isEmpty) return "0.00";
    final scores = _projectProvider.projects
        .where((p) => p.beautyScore != null)
        .map((p) => p.beautyScore!)
        .toList();
    if (scores.isEmpty) return "0.00";
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    return avg.toStringAsFixed(2);
  }

  String get comfortScore {
    if (_projectProvider.projects.isEmpty) return "0.00";
    final scores = _projectProvider.projects
        .where((p) => p.comfortScore != null)
        .map((p) => p.comfortScore!)
        .toList();
    if (scores.isEmpty) return "0.00";
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    return avg.toStringAsFixed(2);
  }

  // Survey List - Recent projects
  List<SurveyItem> get recentSurveys {
    final recentProjects = _projectProvider.getRecentProjects(limit: 3);
    return recentProjects.map((project) {
      return SurveyItem(
        title: project.name,
        subtitle: project.location,
        uviScore: project.averageUVI != null
            ? "UVI ${project.averageUVI!.toStringAsFixed(0)}"
            : "UVI 0",
        time: _formatTime(project.lastOpenedAt ?? project.createdAt),
      );
    }).toList();
  }

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return "00:00";
    }
  }
}
