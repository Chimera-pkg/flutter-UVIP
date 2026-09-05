import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/models/street_photo_model.dart';
import 'package:uvip/models/street_video_model.dart';
import 'package:uvip/providers/upload_provider.dart';
import 'package:uvip/screens/result/result_screen.dart';
import 'package:uvip/widgets/uploaded_item_tile.dart';

class UploadScreen extends StatefulWidget {
  final int initialTab;

  const UploadScreen({super.key, this.initialTab = 0});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late int _currentTab;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UploadProvider>(context, listen: false);
      if (_currentTab == 0) {
        provider.fetchStreetPhotos();
      } else {
        provider.fetchStreetVideos();
      }
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
      if (provider.uploadedPhotos.isEmpty) {
        provider.fetchStreetPhotos();
      }
    } else {
      if (provider.uploadedVideos.isEmpty) {
        provider.fetchStreetVideos();
      }
    }
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final picker = ImagePicker();
    final provider = Provider.of<UploadProvider>(context, listen: false);

    if (_currentTab == 0) {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && context.mounted) {
        await provider.uploadPhoto(image);
      }
    } else {
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null && context.mounted) {
        await provider.uploadVideo(video);
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

    if (confirmed == true && context.mounted) {
      final provider = Provider.of<UploadProvider>(context, listen: false);
      final success = await provider.deletePhoto(photo.id);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Foto berhasil dihapus'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (provider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage!),
              backgroundColor: Colors.redAccent,
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

    if (confirmed == true && context.mounted) {
      final provider = Provider.of<UploadProvider>(context, listen: false);
      final success = await provider.deleteVideo(video.id);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Video berhasil dihapus'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (provider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage!),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          _currentTab == 0 ? 'Upload Foto Kota' : 'Upload Video Kota',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Consumer<UploadProvider>(
        builder: (context, provider, child) {
          final isCurrentlyLoading =
              provider.isLoading &&
              ((_currentTab == 0 && provider.uploadedPhotos.isEmpty) ||
                  (_currentTab == 1 && provider.uploadedVideos.isEmpty));

          if (isCurrentlyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (_currentTab == 0) {
                await provider.fetchStreetPhotos(isRefresh: true);
              } else {
                await provider.fetchStreetVideos(isRefresh: true);
              }
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab Switcher (Foto vs Video)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onTabChanged(0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _currentTab == 0
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _currentTab == 0
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 18,
                                    color: _currentTab == 0
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Foto',
                                    style: TextStyle(
                                      color: _currentTab == 0
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onTabChanged(1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _currentTab == 1
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _currentTab == 1
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.videocam_outlined,
                                    size: 18,
                                    color: _currentTab == 1
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Video',
                                    style: TextStyle(
                                      color: _currentTab == 1
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dotted Dropzone
                  GestureDetector(
                    onTap: provider.isUploading
                        ? null
                        : () => _pickAndUpload(context),
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: provider.isUploading
                            ? Colors.grey
                            : AppTheme.primaryColor,
                        strokeWidth: 2,
                        dashPattern: const [8, 4],
                        radius: const Radius.circular(12),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        decoration: BoxDecoration(
                          color: provider.isUploading
                              ? Colors.grey.withValues(alpha: 0.1)
                              : AppTheme.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _currentTab == 0
                                  ? Icons.upload_rounded
                                  : Icons.video_library_rounded,
                              size: 64,
                              color: provider.isUploading
                                  ? Colors.grey
                                  : AppTheme.primaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              provider.isUploading
                                  ? (_currentTab == 0
                                        ? 'Uploading photo...'
                                        : 'Uploading video...')
                                  : (_currentTab == 0
                                        ? 'Upload your photo here'
                                        : 'Upload your video here'),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.lightGray),
                            ),
                            if (!provider.isUploading) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Browse ${_currentTab == 0 ? 'Photo' : 'Video'}',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppTheme.primaryColor,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Error Message
                  if (provider.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => provider.clearError(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Uploading Section
                  if (provider.isUploading) ...[
                    Text(
                      'Uploading 1 ${_currentTab == 0 ? 'image' : 'video'}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar & Cancel
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: provider.uploadProgress,
                              minHeight: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.secondaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => provider.cancelUpload(),
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Uploaded Photos Section (Tab 0)
                  if (_currentTab == 0) ...[
                    if (provider.uploadedPhotos.isNotEmpty) ...[
                      Text(
                        'Uploaded Photos (${provider.uploadedPhotos.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.uploadedPhotos.length,
                        itemBuilder: (context, index) {
                          final photo = provider.uploadedPhotos[index];
                          return UploadedItemTile(
                            fileName: photo.originalFilename,
                            fileSize: '${photo.fileSizeKb} KB',
                            imageUrl: photo.filePath,
                            isVideo: false,
                            processingStatus: photo.processingStatus,
                            isSelected: provider.selectedPhoto?.id == photo.id,
                            onSelect: (value) =>
                                provider.togglePhotoSelection(photo),
                            onDelete: () =>
                                _confirmAndDeletePhoto(context, photo),
                          );
                        },
                      ),
                      if (provider.isFetchingMorePhotos)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ] else if (!provider.isUploading) ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada foto yang diunggah',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],

                  // Uploaded Videos Section (Tab 1)
                  if (_currentTab == 1) ...[
                    if (provider.uploadedVideos.isNotEmpty) ...[
                      Text(
                        'Uploaded Videos (${provider.uploadedVideos.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.uploadedVideos.length,
                        itemBuilder: (context, index) {
                          final video = provider.uploadedVideos[index];
                          return UploadedItemTile(
                            fileName: video.originalFilename,
                            fileSize: '${video.fileSizeKb} KB',
                            imageUrl: video.filePath,
                            isVideo: true,
                            processingStatus: video.processingStatus,
                            isSelected: provider.selectedVideo?.id == video.id,
                            onSelect: (value) =>
                                provider.toggleVideoSelection(video),
                            onDelete: () =>
                                _confirmAndDeleteVideo(context, video),
                          );
                        },
                      ),
                      if (provider.isFetchingMoreVideos)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ] else if (!provider.isUploading) ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.video_collection_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada video yang diunggah',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 48),

                  // Analisa Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (_currentTab == 0 && provider.selectedPhoto != null && provider.selectedPhoto!.processingStatus == 'completed')
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResultScreen(
                                    photo: provider.selectedPhoto!,
                                  ),
                                ),
                              );
                            }
                          : (_currentTab == 1 && provider.selectedVideo != null && provider.selectedVideo!.processingStatus == 'completed')
                          ? () {
                              final video = provider.selectedVideo!;
                              final photoModel = StreetPhotoModel(
                                id: video.id,
                                missionId: video.missionId,
                                uploadedBy: video.uploadedBy,
                                source: video.source,
                                originalFilename: video.originalFilename,
                                filePath: video.filePath,
                                fileSizeKb: video.fileSizeKb,
                                latitude: video.latitude,
                                longitude: video.longitude,
                                gpsAccuracyM: video.gpsAccuracyM,
                                compassAzimuth: video.compassAzimuth,
                                exifTimestamp: '',
                                isManualCapture: video.isManualCapture,
                                isOfflineSync: video.isOfflineSync,
                                privacyMasked: video.privacyMasked,
                                processingStatus: video.processingStatus,
                                errorMessage: video.errorMessage,
                                capturedAt: video.capturedAt,
                                createdAt: video.createdAt,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResultScreen(
                                    photo: photoModel,
                                    isVideo: true,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Analisa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // padding for bottom nav bar
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
