import 'package:flutter/material.dart';
import 'package:uvip/models/project_model.dart';
import 'package:uvip/services/project_service.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  List<ProjectModel> _projects = [];
  List<ProjectModel> get projects => _projects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProjectModel? _selectedProject;
  ProjectModel? get selectedProject => _selectedProject;

  Future<void> fetchProjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _projectService.getProjects();
      final List<dynamic> data = response.data;
      _projects = data.map((json) => ProjectModel.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat project: $e';
      notifyListeners();
    }
  }

  Future<ProjectModel?> createProject({
    required String name,
    required String location,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _projectService.createProject(
        name: name,
        location: location,
        description: description,
      );
      final newProject = ProjectModel.fromJson(response.data);
      _projects.insert(0, newProject);
      _isLoading = false;
      notifyListeners();
      return newProject;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal membuat project: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> openProject(String projectId) async {
    try {
      final response = await _projectService.openProject(projectId);
      final updatedProject = ProjectModel.fromJson(response.data);

      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        _projects[index] = updatedProject;
        _selectedProject = updatedProject;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Gagal membuka project: $e';
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _projectService.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);
      if (_selectedProject?.id == projectId) {
        _selectedProject = null;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menghapus project: $e';
      notifyListeners();
    }
  }

  void setSelectedProject(ProjectModel? project) {
    _selectedProject = project;
    notifyListeners();
  }

  ProjectModel? getLastOpenedProject() {
    if (_projects.isEmpty) return null;

    final sorted = List<ProjectModel>.from(_projects)
      ..sort((a, b) {
        if (a.lastOpenedAt == null && b.lastOpenedAt == null) return 0;
        if (a.lastOpenedAt == null) return 1;
        if (b.lastOpenedAt == null) return -1;
        return b.lastOpenedAt!.compareTo(a.lastOpenedAt!);
      });

    return sorted.first;
  }

  List<ProjectModel> getRecentProjects({int limit = 3}) {
    final sorted = List<ProjectModel>.from(_projects)
      ..sort((a, b) {
        if (a.lastOpenedAt == null && b.lastOpenedAt == null) return 0;
        if (a.lastOpenedAt == null) return 1;
        if (b.lastOpenedAt == null) return -1;
        return b.lastOpenedAt!.compareTo(a.lastOpenedAt!);
      });

    return sorted.take(limit).toList();
  }

  double getAverageUVI() {
    if (_projects.isEmpty) return 0.0;

    final projectsWithScores = _projects.where((p) => p.averageUVI != null).toList();
    if (projectsWithScores.isEmpty) return 0.0;

    final total = projectsWithScores.fold<double>(
      0.0,
      (sum, project) => sum + project.averageUVI!,
    );

    return total / projectsWithScores.length;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
