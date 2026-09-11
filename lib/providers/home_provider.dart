import 'package:flutter/material.dart';
import 'package:uvip/models/home_dashboard_model.dart';
import 'package:uvip/providers/project_provider.dart';
import 'package:uvip/services/project_service.dart';

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
  final ProjectService _projectService = ProjectService();

  // Chart Data: [Mon, Tue, Wed, Thu, Fri] -> [60, 80, 20, 60, 110]
  final List<double> chartData = [60.0, 80.0, 20.0, 60.0, 110.0];

  // Dynamic data from ProjectProvider
  late final ProjectProvider _projectProvider;

  HomeDashboardModel? _dashboardData;
  HomeDashboardModel? get dashboardData => _dashboardData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setProjectProvider(ProjectProvider projectProvider) {
    _projectProvider = projectProvider;
    notifyListeners();
  }

  Future<void> fetchHomeDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _projectService.getHomeDashboard();
      if (response.statusCode == 200) {
        _dashboardData = HomeDashboardModel.fromJson(response.data);
      } else {
        _errorMessage = 'Gagal memuat data dashboard.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Summary Scores - Dynamic from API or ProjectProvider
  int get totalSurvei =>
      _dashboardData?.totalProjects ?? _projectProvider.projects.length;

  String get rataRataUvi {
    if (_dashboardData?.averageScores?.uviScore != null) {
      return _dashboardData!.averageScores!.uviScore!
          .toDouble()
          .toStringAsFixed(2);
    }
    final avg = _projectProvider.getAverageUVI();
    return avg.toStringAsFixed(2);
  }

  String get safetyScore {
    if (_dashboardData?.averageScores?.safetyScore != null) {
      return _dashboardData!.averageScores!.safetyScore!
          .toDouble()
          .toStringAsFixed(2);
    }
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
    if (_dashboardData?.averageScores?.beautyScore != null) {
      return _dashboardData!.averageScores!.beautyScore!
          .toDouble()
          .toStringAsFixed(2);
    }
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
    if (_dashboardData?.averageScores?.comfortScore != null) {
      return _dashboardData!.averageScores!.comfortScore!
          .toDouble()
          .toStringAsFixed(2);
    }
    if (_projectProvider.projects.isEmpty) return "0.00";
    final scores = _projectProvider.projects
        .where((p) => p.comfortScore != null)
        .map((p) => p.comfortScore!)
        .toList();
    if (scores.isEmpty) return "0.00";
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    return avg.toStringAsFixed(2);
  }

  // Status Category Helper (1-4: Buruk, 5-6: Sedang, 7-10: Baik)
  String getStatusLabel(String scoreStr) {
    final double? score = double.tryParse(scoreStr);
    if (score == null) return 'Baik';
    if (score < 5.0) return 'Buruk';
    if (score < 7.0) return 'Sedang';
    return 'Baik';
  }

  Color getStatusColor(String scoreStr) {
    final double? score = double.tryParse(scoreStr);
    if (score == null) return Colors.green;
    if (score < 5.0) return Colors.red;
    if (score < 7.0) return Colors.orange;
    return Colors.green;
  }

  String get uviStatus => getStatusLabel(rataRataUvi);
  Color get uviStatusColor => getStatusColor(rataRataUvi);

  String get safetyStatus => getStatusLabel(safetyScore);
  Color get safetyStatusColor => getStatusColor(safetyScore);

  String get beautyStatus => getStatusLabel(beautyScore);
  Color get beautyStatusColor => getStatusColor(beautyScore);

  String get comfortStatus => getStatusLabel(comfortScore);
  Color get comfortStatusColor => getStatusColor(comfortScore);

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
