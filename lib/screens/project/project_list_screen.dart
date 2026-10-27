import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/models/project_model.dart';
import 'package:uvip/providers/project_provider.dart';
import 'package:uvip/providers/upload_provider.dart';
import 'package:uvip/screens/project/create_project_bottom_sheet.dart';
import 'package:uvip/screens/upload/upload_screen.dart';
import 'package:uvip/widgets/project_card.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
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
  bool _isGridView = false;
  bool _isAscending = false;

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
    final result = await showCreateProjectBottomSheet(context);
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

  List<ProjectModel> _getSortedProjects(List<ProjectModel> projects) {
    final list = List<ProjectModel>.from(projects);
    list.sort((a, b) {
      final dateA = DateTime.tryParse(a.createdAt) ?? DateTime(1970);
      final dateB = DateTime.tryParse(b.createdAt) ?? DateTime(1970);
      return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
    return list;
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Projects',
          style: TextStyle(
            color: Color(0xFF0F172A),
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

          final sortedProjects = _getSortedProjects(provider.projects);

          return RefreshIndicator(
            onRefresh: () => provider.fetchProjects(isRefresh: true),
            child: Column(
              children: [
                // Subheader: "Latest" sort indicator & Grid/List view toggle
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Latest sort button
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isAscending = !_isAscending;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Latest',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F172A),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isAscending
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Grid / List toggle button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          splashRadius: 20,
                          icon: Icon(
                            _isGridView
                                ? Icons.view_list_rounded
                                : Icons.grid_view_outlined,
                            size: 20,
                            color: const Color(0xFF334155),
                          ),
                          onPressed: () {
                            setState(() {
                              _isGridView = !_isGridView;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Projects Content (List or Grid)
                Expanded(
                  child: _isGridView
                      ? _buildGridView(sortedProjects, provider.isFetchingMore)
                      : _buildListView(sortedProjects, provider.isFetchingMore),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createProject,
        backgroundColor: AppTheme.primaryColor,
        elevation: 3,
        highlightElevation: 5,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add, color: Colors.white, size: 22),
        label: const Text(
          'Project',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<ProjectModel> projects, bool isFetchingMore) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      itemCount: projects.length + (isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == projects.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final project = projects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ProjectCard(
            project: project,
            onTap: () => _openProject(project),
            onDelete: () => _deleteProject(project.id, project.name),
            onMorePressed: (btnContext) =>
                _showProjectDropdown(btnContext, project),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<ProjectModel> projects, bool isFetchingMore) {
    return GridView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: projects.length + (isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == projects.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final project = projects[index];
        return _buildGridCard(project);
      },
    );
  }

  Widget _buildGridCard(ProjectModel project) {
    final fileCount = project.photoCount + project.videoCount;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _openProject(project),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: _buildGridThumbnail(project),
                  ),
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$fileCount files',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (btnContext) {
                        return IconButton(
                          icon: const Icon(Icons.more_horiz),
                          color: const Color(0xFF334155),
                          iconSize: 20,
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              _showProjectDropdown(btnContext, project),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridThumbnail(ProjectModel project) {
    final url = project.thumbnailUrl;
    if (url != null && url.isNotEmpty) {
      String fullUrl = url.replaceAll('\\', '/');
      if (!fullUrl.startsWith('http')) {
        const baseUrl = 'http://80.241.214.39';
        fullUrl =
            '$baseUrl/${fullUrl.startsWith('/') ? fullUrl.substring(1) : fullUrl}';
      }
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackGridThumbnail(),
      );
    }
    return _fallbackGridThumbnail();
  }

  Widget _fallbackGridThumbnail() {
    return Image.network(
      'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=150&auto=format&fit=crop&q=80',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFFE2E8F0),
        child: const Center(
          child: Icon(Icons.streetview, color: Color(0xFF64748B), size: 26),
        ),
      ),
    );
  }
}
