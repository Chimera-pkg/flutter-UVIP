import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/aicam_provider.dart';

class AiCamScreen extends StatefulWidget {
  /// Apakah tab AiCam sedang aktif/terlihat oleh user.
  /// Kamera hanya dinyalakan saat isActive == true.
  final bool isActive;

  const AiCamScreen({super.key, this.isActive = false});

  @override
  State<AiCamScreen> createState() => _AiCamScreenState();
}

class _AiCamScreenState extends State<AiCamScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  Timer? _timer;
  int _liveSeconds = 15; // Starting from 15 as in mockup
  bool _isFlashOn = false;
  bool _permissionDenied = false;
  bool _isInitializing = false; // Guard agar tidak ada inisialisasi paralel

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Hanya init kamera jika tab ini langsung aktif saat pertama kali dibuat
    if (widget.isActive) {
      _initializeCamera();
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant AiCamScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Respond saat tab visibility berubah
    if (widget.isActive && !oldWidget.isActive) {
      // Tab baru saja jadi aktif → nyalakan kamera & timer
      _initializeCamera();
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      // Tab baru saja jadi tidak aktif → matikan kamera & timer
      _disposeCamera();
      _stopTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Hanya handle lifecycle jika tab sedang aktif
    if (!widget.isActive) return;

    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      // Saat kembali dari app settings, cek ulang permission
      if (state == AppLifecycleState.resumed && _permissionDenied) {
        _initializeCamera();
      }
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// Dispose kamera dengan aman, menghindari double-dispose.
  Future<void> _disposeCamera() async {
    final controllerToDispose = _controller;
    _controller = null;
    if (controllerToDispose != null) {
      try {
        await controllerToDispose.dispose();
      } catch (e) {
        debugPrint("Error disposing camera: $e");
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeCamera() async {
    // Cegah inisialisasi paralel (race condition saat pindah tab cepat)
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      // Minta izin kamera secara runtime (wajib untuk Android 6.0+)
      final status = await Permission.camera.request();

      if (!mounted) return;

      if (!status.isGranted) {
        setState(() {
          _permissionDenied = true;
        });
        return;
      }

      setState(() {
        _permissionDenied = false;
      });

      // Dispose controller lama jika ada sebelum buat yang baru
      await _disposeCamera();

      if (!mounted || !widget.isActive) return;

      _cameras = await availableCameras();
      if (!mounted || !widget.isActive) return;

      if (_cameras != null && _cameras!.isNotEmpty) {
        // Gunakan Medium resolution dan matikan audio (enableAudio: false)
        // Jika enableAudio true (default), aplikasi akan force close karena tidak ada izin RECORD_AUDIO
        final controller = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        // Cek lagi sebelum initialize — user mungkin sudah pindah tab
        if (!mounted || !widget.isActive) {
          controller.dispose();
          return;
        }

        _controller = controller;

        await controller.initialize();

        // Jika widget sudah tidak aktif saat proses inisialisasi tertunda
        if (!mounted || !widget.isActive) {
          controller.dispose();
          _controller = null;
          return;
        }

        setState(() {});
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    } finally {
      _isInitializing = false;
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel timer lama jika ada
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && widget.isActive) {
        setState(() {
          _liveSeconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
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
      if (mounted) {
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
      }
    }
  }

  String get _formattedTime {
    int m = _liveSeconds ~/ 60;
    int s = _liveSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Camera Preview or Permission UI
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _permissionDenied
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white54,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Izin Kamera Diperlukan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            'Untuk menggunakan AI Cam, izinkan akses kamera di pengaturan aplikasi.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => openAppSettings(),
                          icon: const Icon(Icons.settings),
                          label: const Text('Buka Pengaturan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _controller != null && _controller!.value.isInitialized
                    ? CameraPreview(_controller!)
                    : const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
          ),

          // Safe Area for UI Overlays
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
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
                          color: _isFlashOn
                              ? Colors.yellowAccent
                              : Colors.white,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Location Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppTheme.primaryColor,
                              size: 16,
                            ),
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
                            _buildLiveScoreItem(
                              'UVI',
                              provider.liveUvi,
                              Colors.blue,
                            ),
                            _buildLiveScoreItem(
                              'Beauty',
                              provider.liveBeauty,
                              Colors.pink,
                            ),
                            _buildLiveScoreItem(
                              'Comfort',
                              provider.liveComfort,
                              Colors.orange,
                            ),
                            _buildLiveScoreItem(
                              'Safety',
                              provider.liveSafety,
                              Colors.green,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  // Bottom Auto Capture Button
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 90.0,
                      ), // Above bottom nav
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
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
