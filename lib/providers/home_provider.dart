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
/// - Skor summary harian (Safety, Beauty, Comfort, Rata-rata UVI)
/// - Daftar survei terbaru
class HomeProvider with ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  // Chart Data: [Mon, Tue, Wed, Thu, Fri] -> [60, 80, 20, 60, 110]
  final List<double> chartData = [60.0, 80.0, 20.0, 60.0, 110.0];

  // Dynamic data from ProjectProvider
  ProjectProvider? _projectProvider;

  HomeDashboardModel? _dashboardData;
  HomeDashboardModel? get dashboardData => _dashboardData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setProjectProvider(ProjectProvider projectProvider) {
    if (_projectProvider != projectProvider) {
      _projectProvider?.removeListener(_onProjectProviderChanged);
      _projectProvider = projectProvider;
      _projectProvider?.addListener(_onProjectProviderChanged);
      notifyListeners();
    }
  }

  void _onProjectProviderChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _projectProvider?.removeListener(_onProjectProviderChanged);
    super.dispose();
  }

  Future<void> fetchHomeDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _projectService.getHomeDashboard();
      if (response.statusCode == 200 || response.statusCode == 201) {
        _dashboardData = HomeDashboardModel.fromJson(response.data);
        debugPrint(
          'fetchHomeDashboard success: total=${_dashboardData?.totalProjects}, '
          'uvi=${_dashboardData?.averageScores?.uviScore}, '
          'safety=${_dashboardData?.averageScores?.safetyScore}, '
          'beauty=${_dashboardData?.averageScores?.beautyScore}, '
          'comfort=${_dashboardData?.averageScores?.comfortScore}',
        );
      } else {
        _errorMessage =
            'Gagal memuat data dashboard (status: ${response.statusCode}).';
        debugPrint(_errorMessage);
      }
    } catch (e, stack) {
      _errorMessage = 'Terjadi kesalahan: $e';
      debugPrint('Error in fetchHomeDashboard: $e\n$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Summary Scores - Dynamic from API or fallback to ProjectProvider
  int get totalSurvei {
    final count = _dashboardData?.totalProjects ?? 0;
    if (count > 0) return count;
    return _projectProvider?.projects.length ?? 0;
  }

  String get rataRataUvi {
    final score = _dashboardData?.averageScores?.uviScore;
    if (score != null && score > 0) {
      return score.toDouble().toStringAsFixed(2);
    }
    final avg = _projectProvider?.getAverageUVI() ?? 0.0;
    if (avg > 0) {
      return avg.toStringAsFixed(2);
    }
    if (score != null) {
      return score.toDouble().toStringAsFixed(2);
    }
    return "0.00";
  }

  String get safetyScore {
    final score = _dashboardData?.averageScores?.safetyScore;
    if (score != null && score > 0) {
      return score.toDouble().toStringAsFixed(2);
    }
    final projects = _projectProvider?.projects ?? [];
    final scores = projects
        .where((p) => p.safetyScore != null && p.safetyScore! > 0)
        .map((p) => p.safetyScore!)
        .toList();
    if (scores.isNotEmpty) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      return avg.toStringAsFixed(2);
    }
    if (score != null) {
      return score.toDouble().toStringAsFixed(2);
    }
    return "0.00";
  }

  String get beautyScore {
    final score = _dashboardData?.averageScores?.beautyScore;
    if (score != null && score > 0) {
      return score.toDouble().toStringAsFixed(2);
    }
    final projects = _projectProvider?.projects ?? [];
    final scores = projects
        .where((p) => p.beautyScore != null && p.beautyScore! > 0)
        .map((p) => p.beautyScore!)
        .toList();
    if (scores.isNotEmpty) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      return avg.toStringAsFixed(2);
    }
    if (score != null) {
      return score.toDouble().toStringAsFixed(2);
    }
    return "0.00";
  }

  String get comfortScore {
    final score = _dashboardData?.averageScores?.comfortScore;
    if (score != null && score > 0) {
      return score.toDouble().toStringAsFixed(2);
    }
    final projects = _projectProvider?.projects ?? [];
    final scores = projects
        .where((p) => p.comfortScore != null && p.comfortScore! > 0)
        .map((p) => p.comfortScore!)
        .toList();
    if (scores.isNotEmpty) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      return avg.toStringAsFixed(2);
    }
    if (score != null) {
      return score.toDouble().toStringAsFixed(2);
    }
    return "0.00";
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
    final recentProjects = _projectProvider?.getRecentProjects(limit: 3) ?? [];
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
