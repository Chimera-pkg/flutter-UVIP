import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/models/project_model.dart';
import 'package:uvip/models/street_photo_model.dart';
import 'package:uvip/models/street_video_model.dart';
import 'package:uvip/providers/upload_provider.dart';
import 'package:uvip/providers/project_provider.dart';
import 'package:uvip/providers/map_provider.dart';
import 'package:uvip/screens/result/result_screen.dart';
import 'package:uvip/widgets/video_preview_dialog.dart';

class UploadScreen extends StatefulWidget {
  final int initialTab;
  final String? projectId;
  final ProjectModel? project;

  const UploadScreen({
    super.key,
    this.initialTab = 0,
    this.projectId,
    this.project,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late int _currentTab;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  ProjectModel? _currentProject;
  bool _isGridView = true;
  final String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _currentProject = widget.project;
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uploadProvider = Provider.of<UploadProvider>(
        context,
        listen: false,
      );
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );

      final pId = _currentProject?.id ?? widget.projectId;
      uploadProvider.setCurrentProjectId(pId);

      if (_currentProject == null && pId != null) {
        final matches = projectProvider.projects.where((p) => p.id == pId);
        if (matches.isNotEmpty) {
          setState(() {
            _currentProject = matches.first;
          });
        }
      }

      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      if (!mapProvider.isLocationLoaded) {
        mapProvider.determinePosition();
      }

      uploadProvider.fetchStreetPhotos();
      uploadProvider.fetchStreetVideos();
    });
  }

  @override
  void didUpdateWidget(covariant UploadScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      _onTabChanged(widget.initialTab);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<UploadProvider>(context, listen: false);
      if (_currentTab == 0) {
        if (!provider.isFetchingMorePhotos) {
          provider.fetchStreetPhotos(isLoadMore: true);
        }
      } else {
        if (!provider.isFetchingMoreVideos) {
          provider.fetchStreetVideos(isLoadMore: true);
        }
      }
    }
  }

  void _onTabChanged(int index) {
    if (_currentTab == index) return;
    setState(() {
      _currentTab = index;
    });
    final provider = Provider.of<UploadProvider>(context, listen: false);
    if (index == 0) {
      if (!provider.hasFetchedPhotos && !provider.isLoadingPhotos) {
        provider.fetchStreetPhotos();
      }
    } else {
      if (!provider.hasFetchedVideos && !provider.isLoadingVideos) {
        provider.fetchStreetVideos();
      }
    }
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final provider = Provider.of<UploadProvider>(context, listen: false);
    if (provider.isUploading) return;

    final picker = ImagePicker();

    if (_currentTab == 0) {
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty && context.mounted) {
        final mapProvider = Provider.of<MapProvider>(context, listen: false);
        if (!mapProvider.isLocationLoaded) {
          await mapProvider.determinePosition();
        }
        if (images.length == 1) {
          await provider.uploadPhoto(
            images.first,
            latitude: mapProvider.latitude,
            longitude: mapProvider.longitude,
            locationName: mapProvider.locationName,
          );
        } else {
          await provider.uploadPhotosBulk(
            images,
            latitude: mapProvider.latitude,
            longitude: mapProvider.longitude,
            locationName: mapProvider.locationName,
          );
        }
      }
    } else {
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null && context.mounted) {
        final mapProvider = Provider.of<MapProvider>(context, listen: false);
        if (!mapProvider.isLocationLoaded) {
          await mapProvider.determinePosition();
        }
        await provider.uploadVideo(
          video,
          latitude: mapProvider.latitude,
          longitude: mapProvider.longitude,
          locationName: mapProvider.locationName,
        );
      }
    }
  }

  Future<void> _confirmAndDeletePhoto(
    BuildContext context,
    StreetPhotoModel photo,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Hapus Foto?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${photo.originalFilename.isNotEmpty ? photo.originalFilename : 'foto ini'}"? Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Menghapus foto...'),
            ],
          ),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final provider = Provider.of<UploadProvider>(context, listen: false);
      final success = await provider.deletePhoto(photo.id);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto berhasil dihapus'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Gagal menghapus foto'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmAndDeleteVideo(
    BuildContext context,
    StreetVideoModel video,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Hapus Video?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${video.originalFilename.isNotEmpty ? video.originalFilename : 'video ini'}"? Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Menghapus video...'),
            ],
          ),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final provider = Provider.of<UploadProvider>(context, listen: false);
      final success = await provider.deleteVideo(video.id);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video berhasil dihapus'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Gagal menghapus video'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showImagePreview(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVideoPreview(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return VideoPreviewDialog(videoUrl: url, title: title);
      },
    );
  }

  void _showProjectSelectionModal() {
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    final projects = projectProvider.projects;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Pilih Proyek',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (projects.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('Tidak ada proyek tersedia.'),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: projects.length,
                      itemBuilder: (itemCtx, index) {
                        final p = projects[index];
                        final isSelected = _currentProject?.id == p.id;
                        return ListTile(
                          leading: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.folder_outlined,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey,
                          ),
                          title: Text(
                            p.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${p.photoCount} Foto, ${p.videoCount} Video',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            if (_currentProject?.id != p.id) {
                              setState(() {
                                _currentProject = p;
                              });
                              final uploadProvider =
                                  Provider.of<UploadProvider>(
                                    context,
                                    listen: false,
                                  );
                              uploadProvider.setCurrentProjectId(p.id);
                              uploadProvider.fetchStreetPhotos(isRefresh: true);
                              uploadProvider.fetchStreetVideos(isRefresh: true);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPhotoOptions(
    BuildContext context,
    StreetPhotoModel photo,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          photo.originalFilename.isNotEmpty
                              ? photo.originalFilename
                              : 'Foto',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Color(0xFF03182C),
                  ),
                  title: const Text(
                    'Lihat Detail Analisis',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(modalContext, 'detail'),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.fullscreen,
                    color: Color(0xFF03182C),
                  ),
                  title: const Text(
                    'Pratinjau Foto',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(modalContext, 'preview'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Hapus Foto',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => Navigator.pop(modalContext, 'delete'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'detail') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen(photo: photo)),
      );
    } else if (action == 'preview') {
      _showImagePreview(context, _resolveUrl(photo.filePath));
    } else if (action == 'delete') {
      _confirmAndDeletePhoto(context, photo);
    }
  }

  Future<void> _showVideoOptions(
    BuildContext context,
    StreetVideoModel video,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.originalFilename.isNotEmpty
                              ? video.originalFilename
                              : 'Video',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Color(0xFF03182C),
                  ),
                  title: const Text(
                    'Lihat Detail Analisis',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(modalContext, 'detail'),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.play_circle_outline,
                    color: Color(0xFF03182C),
                  ),
                  title: const Text(
                    'Putar Video',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(modalContext, 'preview'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Hapus Video',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => Navigator.pop(modalContext, 'delete'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'detail') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(video: video, isVideo: true),
        ),
      );
    } else if (action == 'preview') {
      _showVideoPreview(
        context,
        _resolveUrl(video.filePath),
        video.originalFilename,
      );
    } else if (action == 'delete') {
      _confirmAndDeleteVideo(context, video);
    }
  }

  String _resolveUrl(String path) {
    String fullUrl = path.replaceAll('\\', '/');
    if (!fullUrl.startsWith('http')) {
      const baseUrl = 'http://80.241.214.39';
      fullUrl =
          '$baseUrl/${fullUrl.startsWith('/') ? fullUrl.substring(1) : fullUrl}';
    }
    return fullUrl;
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
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Galeri Proyek',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.format_list_bulleted : Icons.grid_view,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<UploadProvider>(
        builder: (context, provider, child) {
          final isCurrentlyLoading = _currentTab == 0
              ? (provider.isLoadingPhotos && provider.uploadedPhotos.isEmpty)
              : (provider.isLoadingVideos && provider.uploadedVideos.isEmpty);

          if (isCurrentlyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final photos = provider.uploadedPhotos.where((p) {
            if (_searchQuery.isEmpty) return true;
            return p.originalFilename.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();

          final videos = provider.uploadedVideos.where((v) {
            if (_searchQuery.isEmpty) return true;
            return v.originalFilename.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();

          final photoCount = provider.hasFetchedPhotos
              ? provider.totalPhotoData
              : (_currentProject?.totalPhotos ?? provider.totalPhotoData);
          final videoCount = provider.hasFetchedVideos
              ? provider.totalVideoData
              : (_currentProject?.totalVideos ?? provider.totalVideoData);
          final projectName = _currentProject?.name.isNotEmpty == true
              ? _currentProject!.name
              : 'Alun-Alun Tugu';

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                provider.fetchStreetPhotos(isRefresh: true),
                provider.fetchStreetVideos(isRefresh: true),
              ]);
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Project Dropdown Card
                  GestureDetector(
                    onTap: _showProjectSelectionModal,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              projectName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF0F172A),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Info Row (Photo/Video Count + Status Badge)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$photoCount Foto, $videoCount Video',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Tab Switcher & Action Icons
                  Row(
                    children: [
                      // Capsule Tab Switcher (Foto vs Video)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _onTabChanged(0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentTab == 0
                                      ? const Color(0xFF071526)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Foto',
                                  style: TextStyle(
                                    color: _currentTab == 0
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _onTabChanged(1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentTab == 1
                                      ? const Color(0xFF071526)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Video',
                                  style: TextStyle(
                                    color: _currentTab == 1
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Upload Progress Banner (if uploading)
                  if (provider.isUploading) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF03182C).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mengunggah ${_currentTab == 0 ? 'Foto' : 'Video'}...',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: provider.uploadProgress > 0
                                        ? provider.uploadProgress
                                        : null,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF02BDDB),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () => provider.cancelUpload(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 4. Content Area: Grid / List of Photos or Videos
                  if (_currentTab == 0) ...[
                    // Foto Content
                    if (photos.isEmpty && !provider.isUploading)
                      _buildEmptyState(
                        'Belum ada foto dalam proyek ini',
                        () => _pickAndUpload(context),
                      )
                    else if (_isGridView)
                      _buildPhotoGrid(photos)
                    else
                      _buildPhotoList(photos),
                    if (provider.isFetchingMorePhotos)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ] else ...[
                    // Video Content
                    if (videos.isEmpty && !provider.isUploading)
                      _buildEmptyState(
                        'Belum ada video dalam proyek ini',
                        () => _pickAndUpload(context),
                      )
                    else if (_isGridView)
                      _buildVideoGrid(videos)
                    else
                      _buildVideoList(videos),
                    if (provider.isFetchingMoreVideos)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'upload_fab',
        onPressed: () => _pickAndUpload(context),
        backgroundColor: const Color(0xFF071526),
        elevation: 4,
        shape: const CircleBorder(),
        tooltip: _currentTab == 0 ? 'Tambah Foto' : 'Tambah Video',
        child: Icon(
          _currentTab == 0
              ? Icons.add_photo_alternate_outlined
              : Icons.video_call_outlined,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, VoidCallback onUpload) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          children: [
            Icon(
              _currentTab == 0
                  ? Icons.photo_library_outlined
                  : Icons.video_collection_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload, size: 18),
              label: Text(_currentTab == 0 ? 'Unggah Foto' : 'Unggah Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF071526),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(List<StreetPhotoModel> photos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.74,
      ),
      itemBuilder: (context, index) {
        final photo = photos[index];
        final fullUrl = _resolveUrl(photo.filePath);
        final fileName = photo.originalFilename.isNotEmpty
            ? photo.originalFilename.toUpperCase()
            : 'IMG_${index + 123}.JPG';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Icon + File Name + More Icon
            Row(
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 18,
                  color: Color(0xFF03182C),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPhotoOptions(context, photo),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.more_horiz,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Image Thumbnail
            Expanded(
              child: GestureDetector(
                onTap: () => _showImagePreview(context, fullUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFE2E8F0),
                    child: Image.network(
                      fullUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(
                            Icons.streetview,
                            color: Color(0xFF94A3B8),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // UVI Score
            Center(
              child: Text(
                (photo.streetName != null &&
                        photo.streetName!.trim().isNotEmpty)
                    ? photo.streetName!
                    : "-",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            // "Lihat Detail" Button
            if (photo.processingStatus.toLowerCase() == 'completed')
              SizedBox(
                width: double.infinity,
                height: 34,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(photo: photo),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF02BDDB),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Lihat Detail',
                    style: TextStyle(
                      color: Color(0xFF02BDDB),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            if (photo.processingStatus.toLowerCase() != 'completed')
              SizedBox(
                width: double.infinity,
                height: 34,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    photo.processingStatus,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPhotoList(List<StreetPhotoModel> photos) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        final fullUrl = _resolveUrl(photo.filePath);
        final fileName = photo.originalFilename.isNotEmpty
            ? photo.originalFilename.toUpperCase()
            : 'IMG_${index + 123}.JPG';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.network(
                    fullUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(
                        Icons.streetview,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (photo.streetName != null &&
                              photo.streetName!.trim().isNotEmpty)
                          ? photo.streetName!
                          : "-",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (photo.processingStatus.toLowerCase() == 'completed')
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(photo: photo),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF02BDDB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text(
                    'Lihat Detail',
                    style: TextStyle(color: Color(0xFF02BDDB), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (photo.processingStatus.toLowerCase() != 'completed')
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    photo.processingStatus,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              GestureDetector(
                onTap: () => _showPhotoOptions(context, photo),
                child: const Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoGrid(List<StreetVideoModel> videos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.74,
      ),
      itemBuilder: (context, index) {
        final video = videos[index];
        final fullUrl = _resolveUrl(video.filePath);
        final fileName = video.originalFilename.isNotEmpty
            ? video.originalFilename.toUpperCase()
            : 'IMG_${index + 123}.JPG';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Video Badge Icon + File Name + More Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03182C),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showVideoOptions(context, video),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.more_horiz,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Video Thumbnail
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    _showVideoPreview(context, fullUrl, video.originalFilename),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFE2E8F0),
                    child: Image.network(
                      fullUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(
                            Icons.videocam_outlined,
                            color: Color(0xFF94A3B8),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // UVI Score
            Center(
              child: Text(
                (video.streetName != null &&
                        video.streetName!.trim().isNotEmpty)
                    ? video.streetName!
                    : "-",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            // "Lihat Detail" Button
            if (video.processingStatus.toLowerCase() == 'completed')
              SizedBox(
                width: double.infinity,
                height: 34,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ResultScreen(video: video, isVideo: true),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF02BDDB),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Lihat Detail',
                    style: TextStyle(
                      color: Color(0xFF02BDDB),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            if (video.processingStatus.toLowerCase() != 'completed')
              SizedBox(
                width: double.infinity,
                height: 34,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    video.processingStatus,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildVideoList(List<StreetVideoModel> videos) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        final fullUrl = _resolveUrl(video.filePath);
        final fileName = video.originalFilename.isNotEmpty
            ? video.originalFilename.toUpperCase()
            : 'IMG_${index + 123}.JPG';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.network(
                    fullUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(
                        Icons.videocam_outlined,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (video.streetName != null &&
                              video.streetName!.trim().isNotEmpty)
                          ? video.streetName!
                          : "-",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (video.processingStatus.toLowerCase() == 'completed')
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ResultScreen(video: video, isVideo: true),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF02BDDB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text(
                    'Lihat Detail',
                    style: TextStyle(color: Color(0xFF02BDDB), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (video.processingStatus.toLowerCase() != 'completed')
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    video.processingStatus,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              GestureDetector(
                onTap: () => _showVideoOptions(context, video),
                child: const Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
