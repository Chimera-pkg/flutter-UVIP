import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/aicam_provider.dart';
import 'package:uvip/widgets/object_detector_box.dart';

class AiCamScreen extends StatefulWidget {
  const AiCamScreen({super.key});

  @override
  State<AiCamScreen> createState() => _AiCamScreenState();
}

class _AiCamScreenState extends State<AiCamScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  
  Timer? _timer;
  int _liveSeconds = 15; // Starting from 15 as in mockup
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startTimer();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Use the first camera (usually the back camera)
        _controller = CameraController(_cameras![0], ResolutionPreset.high);
        await _controller!.initialize();
        if (!mounted) return;
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _liveSeconds++;
        });
      }
    });
  }

  void _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint("Error toggling flash: $e");
      // Revert state if it fails
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  String get _formattedTime {
    int m = _liveSeconds ~/ 60;
    int s = _liveSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Camera Preview
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _controller != null && _controller!.value.isInitialized
                ? CameraPreview(_controller!)
                : const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
          ),
          
          // Bounding Boxes Layer
          Consumer<AiCamProvider>(
            builder: (context, provider, child) {
              return Stack(
                children: provider.detectedObjects.map((obj) {
                  return ObjectDetectorBox(
                    rect: obj.rect,
                    label: obj.label,
                    score: obj.score,
                    color: obj.color,
                  );
                }).toList(),
              );
            },
          ),

          // Safe Area for UI Overlays
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                      const Text(
                        'AI Cam',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off, 
                          color: _isFlashOn ? Colors.yellowAccent : Colors.white, 
                          size: 28,
                        ),
                        onPressed: _toggleFlash,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Sub-top Row (Live timer & Location)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Live Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Live $_formattedTime',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // Location Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 16),
                            const SizedBox(width: 4),
                            const Text(
                              'Jl. Ijen',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Left Floating Score Panel
                  Container(
                    width: 140,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Consumer<AiCamProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Live Score',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildLiveScoreItem('UVI', provider.liveUvi, Colors.blue),
                            _buildLiveScoreItem('Beauty', provider.liveBeauty, Colors.pink),
                            _buildLiveScoreItem('Comfort', provider.liveComfort, Colors.orange),
                            _buildLiveScoreItem('Safety', provider.liveSafety, Colors.green),
                          ],
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  // Bottom Auto Capture Button
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 90.0), // Above bottom nav
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.timer_outlined, size: 20),
                        label: const Text(
                          'Auto Capture',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveScoreItem(String label, double score, Color bulletColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: bulletColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
