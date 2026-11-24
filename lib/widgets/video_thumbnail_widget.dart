import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final BoxFit fit;
  final bool isSmall;
  final bool showPlayIcon;

  const VideoThumbnailWidget({
    super.key,
    required this.videoUrl,
    this.fit = BoxFit.cover,
    this.isSmall = false,
    this.showPlayIcon = true,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initThumbnail();
  }

  @override
  void didUpdateWidget(covariant VideoThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _hasError = false;
      _initThumbnail();
    }
  }

  Future<void> _initThumbnail() async {
    if (widget.videoUrl.trim().isEmpty) {
      if (mounted) setState(() => _hasError = true);
      return;
    }

    try {
      final cleanUrl = widget.videoUrl.replaceAll('\\', '/');
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
        debugPrint('VideoThumbnail: load with headers failed ($firstError), retrying without headers');
        controller = VideoPlayerController.networkUrl(uri);
        await controller.initialize();
      }

      if (!mounted) {
        controller.dispose();
        return;
      }

      await controller.setVolume(0.0);
      await controller.pause();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
      } else {
        controller.dispose();
      }
    } catch (e) {
      debugPrint('VideoThumbnail error for ${widget.videoUrl}: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: const Color(0xFFF1F5F9),
        child: Center(
          child: Icon(
            Icons.videocam_outlined,
            color: const Color(0xFF94A3B8),
            size: widget.isSmall ? 22 : 28,
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: const Color(0xFFE2E8F0),
        child: Center(
          child: SizedBox(
            width: widget.isSmall ? 16 : 20,
            height: widget.isSmall ? 16 : 20,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
      );
    }

    final size = _controller!.value.size;
    final double videoWidth = size.width > 0 ? size.width : 16;
    final double videoHeight = size.height > 0 ? size.height : 9;

    return Stack(
      fit: StackFit.expand,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: widget.fit,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: videoWidth,
              height: videoHeight,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
        if (widget.showPlayIcon)
          Center(
            child: Container(
              padding: EdgeInsets.all(widget.isSmall ? 4 : 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: widget.isSmall ? 16 : 22,
              ),
            ),
          ),
      ],
    );
  }
}
