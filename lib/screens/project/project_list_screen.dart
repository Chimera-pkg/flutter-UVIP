import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/models/project_model.dart';
import 'package:uvip/providers/project_provider.dart';
import 'package:uvip/widgets/project_card.dart';
import 'package:uvip/screens/project/create_project_screen.dart';
import 'package:uvip/providers/upload_provider.dart';
import 'package:uvip/screens/upload/upload_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectDateGroup {
  final String dateHeader;
  final DateTime? date;
  final List<ProjectModel> projects;

  _ProjectDateGroup({
    required this.dateHeader,
    this.date,
    required this.projects,
  });
}

class _CustomMenuDivider extends PopupMenuEntry<Never> {
  const _CustomMenuDivider();

  @override
  final double height = 1.0;

  @override
  bool represents(void value) => false;

  @override
  State<_CustomMenuDivider> createState() => _CustomMenuDividerState();
}

class _CustomMenuDividerState extends State<_CustomMenuDivider> {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));
  }
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProjectProvider>(context, listen: false);
      provider.fetchProjects();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<ProjectProvider>(context, listen: false);
      if (!provider.isFetchingMore) {
        provider.fetchProjects(isLoadMore: true);
      }
    }
  }

  Future<void> _createProject() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateProjectScreen()),
    );

    if (result != null && mounted) {
      final provider = Provider.of<ProjectProvider>(context, listen: false);
      await provider.fetchProjects();
    }
  }

  Future<void> _deleteProject(String projectId, String projectName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Project'),
        content: Text(
          'Apakah Anda yakin ingin menghapus project "$projectName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<ProjectProvider>(context, listen: false);
      await provider.deleteProject(projectId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _openProject(ProjectModel project) {
    final uploadProvider = Provider.of<UploadProvider>(context, listen: false);
    uploadProvider.setCurrentProjectId(project.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadScreen(
          projectId: project.id,
          project: project,
          initialTab: 0,
        ),
      ),
    );
  }

  void _showProjectDropdown(
    BuildContext? buttonContext,
    ProjectModel project,
  ) async {
    RelativeRect position;
    if (buttonContext != null) {
      final RenderBox? button = buttonContext.findRenderObject() as RenderBox?;
      final RenderBox? overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox?;
      if (button != null && overlay != null) {
        final buttonTopLeft = button.localToGlobal(
          Offset.zero,
          ancestor: overlay,
        );
        final buttonBottomRight = button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        );
        position = RelativeRect.fromRect(
          Rect.fromPoints(
            Offset(buttonTopLeft.dx, buttonBottomRight.dy),
            buttonBottomRight,
          ),
          Offset.zero & overlay.size,
        );
      } else {
        position = const RelativeRect.fromLTRB(100, 200, 20, 0);
      }
    } else {
      position = const RelativeRect.fromLTRB(100, 200, 20, 0);
    }

    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.06), width: 1),
      ),
      constraints: const BoxConstraints(minWidth: 175, maxWidth: 220),
      items: [
        PopupMenuItem<String>(
          value: 'open',
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              const Icon(
                Icons.folder_open_outlined,
                color: Color(0xFF03182C),
                size: 22,
              ),
              const SizedBox(width: 14),
              const Text(
                'Buka proyek',
                style: TextStyle(
                  color: Color(0xFF03182C),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const _CustomMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFE53935),
                size: 22,
              ),
              const SizedBox(width: 14),
              const Text(
                'Hapus proyek',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (selected == 'open') {
      _openProject(project);
    } else if (selected == 'delete') {
      _deleteProject(project.id, project.name);
    }
  }

  DateTime? _parseDateTime(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        final parts = dateStr.split(RegExp(r'[-/]'));
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            return DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          } else if (parts[2].length == 4) {
            return DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }
      } catch (_) {}
      return null;
    }
  }

  String _formatIndonesianDate(DateTime date) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  List<_ProjectDateGroup> _groupProjectsByDate(List<ProjectModel> projects) {
    final Map<String, _ProjectDateGroup> groupMap = {};

    for (final project in projects) {
      final parsed = _parseDateTime(project.createdAt);
      final header = parsed != null ? _formatIndonesianDate(parsed) : 'Lainnya';

      if (!groupMap.containsKey(header)) {
        groupMap[header] = _ProjectDateGroup(
          dateHeader: header,
          date: parsed,
          projects: [],
        );
      }
      groupMap[header]!.projects.add(project);
    }

    return groupMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          'Proyek Saya',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => provider.fetchProjects(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Coba Lagi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada project',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai dengan membuat project baru',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final groups = _groupProjectsByDate(provider.projects);

          return RefreshIndicator(
            onRefresh: () => provider.fetchProjects(isRefresh: true),
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: groups.length + (provider.isFetchingMore ? 1 : 0),
              itemBuilder: (context, groupIndex) {
                if (groupIndex == groups.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final group = groups[groupIndex];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                        child: Text(
                          group.dateHeader,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      ...group.projects.map((project) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: ProjectCard(
                            project: project,
                            onTap: () => _openProject(project),
                            onDelete: () =>
                                _deleteProject(project.id, project.name),
                            onMorePressed: (btnContext) =>
                                _showProjectDropdown(btnContext, project),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom > 0
              ? MediaQuery.of(context).padding.bottom + 8
              : 20,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _createProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF071526),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Buat Proyek Baru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
