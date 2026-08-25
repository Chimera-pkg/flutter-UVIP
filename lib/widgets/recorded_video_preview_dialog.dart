import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:uvip/core/theme/app_theme.dart';

class RecordedVideoPreviewDialog extends StatefulWidget {
  final XFile videoFile;
  final Future<void> Function() onConfirmUpload;
  final VoidCallback? onCancel;

  const RecordedVideoPreviewDialog({
    super.key,
    required this.videoFile,
    required this.onConfirmUpload,
    this.onCancel,
  });

  @override
  State<RecordedVideoPreviewDialog> createState() =>
      _RecordedVideoPreviewDialogState();
}

class _RecordedVideoPreviewDialogState
    extends State<RecordedVideoPreviewDialog> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isUploading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (kIsWeb) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoFile.path),
        );
      } else {
        _controller = VideoPlayerController.file(File(widget.videoFile.path));
      }

      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error loading recorded video: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      _controller!.value.isPlaying
          ? _controller!.pause()
          : _controller!.play();
    });
  }

  Future<void> _handleConfirm() async {
    if (_isUploading) return;
    setState(() {
      _isUploading = true;
    });

    try {
      await widget.onConfirmUpload();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint("Error confirming upload: $e");
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _handleCancel() {
    if (_isUploading) return;
    widget.onCancel?.call();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxDialogHeight = screenSize.height * 0.88;
    final maxDialogWidth =
        screenSize.width > 640 ? 600.0 : screenSize.width * 0.94;

    return PopScope(
      canPop: !_isUploading,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxDialogWidth,
              maxHeight: maxDialogHeight,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: Colors.black87,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.videocam_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Hasil Rekaman Video',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!_isUploading)
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white70,
                                size: 22,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: _handleCancel,
                            ),
                        ],
                      ),
                    ),

                    // Video Content Body (Flexible)
                    Flexible(
                      child: Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: _buildVideoBody(),
                      ),
                    ),

                    // Video Scrubber Bar (if initialized)
                    if (_isInitialized && _controller != null)
                      _buildScrubberBar(),

                    // Action Buttons (Ulangi & Upload)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFF1E1E1E),
                      child: Row(
                        children: [
                          // Button Ulangi / Batal
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: _isUploading ? null : _handleCancel,
                              icon: const Icon(
                                Icons.replay_rounded,
                                size: 18,
                                color: Colors.white70,
                              ),
                              label: const Text(
                                'Ulangi',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Button Simpan & Upload
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: _isUploading ? null : _handleConfirm,
                              icon: _isUploading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.cloud_upload_rounded,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                _isUploading ? 'Menyimpan...' : 'Upload Video',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoBody() {
    if (_isInitialized && _controller != null) {
      final videoAspectRatio = _controller!.value.aspectRatio > 0
          ? _controller!.value.aspectRatio
          : 16 / 9;

      return GestureDetector(
        onTap: _togglePlayPause,
        child: AspectRatio(
          aspectRatio: videoAspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller!),

              // Play/Pause Overlay Icon
              if (!_controller!.value.isPlaying)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Gagal memuat video rekaman',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return const Center(
      child: CircularProgressIndicator(color: AppTheme.primaryColor),
    );
  }

  Widget _buildScrubberBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      color: Colors.black54,
      child: ValueListenableBuilder(
        valueListenable: _controller!,
        builder: (context, VideoPlayerValue value, child) {
          final maxDuration = value.duration.inMilliseconds.toDouble();
          final currentPosition = value.position.inMilliseconds
              .clamp(0, value.duration.inMilliseconds)
              .toDouble();

          return Row(
            children: [
              IconButton(
                icon: Icon(
                  value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _togglePlayPause,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(value.position),
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
                    trackHeight: 3,
                    activeTrackColor: AppTheme.primaryColor,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppTheme.primaryColor,
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: maxDuration > 0 ? currentPosition : 0.0,
                    min: 0.0,
                    max: maxDuration > 0 ? maxDuration : 1.0,
                    onChanged: maxDuration > 0
                        ? (pos) {
                            _controller!.seekTo(
                              Duration(milliseconds: pos.toInt()),
                            );
                          }
                        : null,
                  ),
                ),
              ),
              Text(
                _formatDuration(value.duration),
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          );
        },
      ),
    );
  }
}
