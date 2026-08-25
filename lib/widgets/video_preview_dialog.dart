import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:uvip/core/theme/app_theme.dart';

class VideoPreviewDialog extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const VideoPreviewDialog({super.key, required this.videoUrl, this.title});

  @override
  State<VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<VideoPreviewDialog> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      String cleanUrl = widget.videoUrl.replaceAll('\\', '/');
      final uri = Uri.parse(Uri.encodeFull(cleanUrl));

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      VideoPlayerController controller;
      try {
        controller = VideoPlayerController.networkUrl(
          uri,
          httpHeaders: headers.isNotEmpty ? headers : const {},
        );
        await controller.initialize();
      } catch (firstError) {
        debugPrint("Initial load with headers failed ($firstError), retrying without headers...");
        controller = VideoPlayerController.networkUrl(uri);
        await controller.initialize();
      }

      _controller = controller;
      await controller.setLooping(true);
      await controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error loading video: $e");
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
      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
    });
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxDialogHeight = screenSize.height * 0.85;
    final maxDialogWidth = screenSize.width > 640
        ? 600.0
        : screenSize.width * 0.92;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxDialogWidth,
            maxHeight: maxDialogHeight,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
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
                  // Header (Title & Close Button)
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
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title ?? 'Video Preview',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 22,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Video Body (Flexible container with aspect ratio containment)
                  Flexible(
                    child: Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: _buildVideoBody(),
                    ),
                  ),

                  // Controls Footer
                  if (_isInitialized && _controller != null)
                    _buildControlsFooter(),
                ],
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

              // Play/Pause Center Overlay Button
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
                'Gagal memuat video',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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

  Widget _buildControlsFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: Colors.black87,
      child: ValueListenableBuilder(
        valueListenable: _controller!,
        builder: (context, VideoPlayerValue value, child) {
          final maxDuration = value.duration.inMilliseconds.toDouble();
          final currentPosition = value.position.inMilliseconds
              .clamp(0, value.duration.inMilliseconds)
              .toDouble();

          return Row(
            children: [
              // Play/Pause Button
              IconButton(
                icon: Icon(
                  value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _togglePlayPause,
              ),
              const SizedBox(width: 8),

              // Current Position Text
              Text(
                _formatDuration(value.position),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),

              // Scrubber Slider
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    trackHeight: 3,
                    activeTrackColor: AppTheme.primaryColor,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppTheme.primaryColor,
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
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

              // Total Duration Text
              Text(
                _formatDuration(value.duration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 6),

              // Mute/Unmute Button
              IconButton(
                icon: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _toggleMute,
              ),
            ],
          );
        },
      ),
    );
  }
}
