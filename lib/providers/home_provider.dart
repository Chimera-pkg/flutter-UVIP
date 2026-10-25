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

  // Helper untuk normalisasi skor ke rentang 0.0 - 1.0 jika berada dalam skala 10 atau 100
  static double? parseAndNormalizeScore(String? scoreStr) {
    if (scoreStr == null) return null;
    final double? rawScore = double.tryParse(scoreStr);
    if (rawScore == null) return null;
    if (rawScore < 0.0) return rawScore;
    if (rawScore > 10.0) {
      return rawScore / 100.0;
    } else if (rawScore > 1.0) {
      return rawScore / 10.0;
    }
    return rawScore;
  }

  // Parameter PVI Hasil Proyeksi:
  // Level 1: Sangat rendah (Tidak terjangkau oleh prediksi model)
  // Level 2: Rendah (0,0000 - < 0,0492)
  // Level 3: Cenderung rendah (0,0492 - < 0,1704)
  // Level 4: Sedang (0,1704 - < 0,2917)
  // Level 5: Cenderung tinggi (0,2917 - < 0,4130)
  // Level 6: Tinggi (0,4130 - < 0,5343)
  // Level 7: Sangat tinggi (0,5343 - 1,0000)
  String getStatusLabel(String scoreStr) {
    final double? normScore = parseAndNormalizeScore(scoreStr);
    if (normScore == null || normScore < 0.0) {
      return 'Sangat rendah';
    }
    if (normScore < 0.0492) {
      return 'Rendah';
    }
    if (normScore < 0.1704) {
      return 'Cenderung rendah';
    }
    if (normScore < 0.2917) {
      return 'Sedang';
    }
    if (normScore < 0.4130) {
      return 'Cenderung tinggi';
    }
    if (normScore < 0.5343) {
      return 'Tinggi';
    }
    return 'Sangat tinggi';
  }

  Color getStatusColor(String scoreStr) {
    final double? normScore = parseAndNormalizeScore(scoreStr);
    if (normScore == null || normScore < 0.0) {
      return const Color(0xFFC62828); // Level 1: Sangat rendah
    }
    if (normScore < 0.0492) {
      return const Color(0xFFE53935); // Level 2: Rendah
    }
    if (normScore < 0.1704) {
      return const Color(0xFFFF7043); // Level 3: Cenderung rendah
    }
    if (normScore < 0.2917) {
      return const Color(0xFFFFA000); // Level 4: Sedang
    }
    if (normScore < 0.4130) {
      return const Color(0xFF4CAF50); // Level 5: Cenderung tinggi
    }
    if (normScore < 0.5343) {
      return const Color(0xFF00BFA5); // Level 6: Tinggi
    }
    return const Color(0xFF02BDDB); // Level 7: Sangat tinggi
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
            ? "PVI ${project.averageUVI!.toStringAsFixed(0)}"
            : "PVI 0",
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
