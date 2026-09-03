import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/aicam_provider.dart';
import 'package:uvip/providers/upload_provider.dart';
import 'package:uvip/screens/upload/upload_screen.dart';
import 'package:uvip/widgets/object_detector_box.dart';
import 'package:uvip/widgets/recorded_video_preview_dialog.dart';

enum CameraMode { photo, video }

class AiCamScreen extends StatefulWidget {
  /// Apakah tab AiCam sedang aktif/terlihat oleh user.
  /// Kamera hanya dinyalakan saat isActive == true.
  final bool isActive;
  final void Function(int tabIndex)? onSwitchToUpload;

  const AiCamScreen({super.key, this.isActive = false, this.onSwitchToUpload});

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
  bool _isCapturing = false; // Guard saat proses pengambilan foto & simpan

  // Video recording state
  CameraMode _mode = CameraMode.photo;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  bool _isStreaming = false; // Guard untuk image stream ML Kit

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
      _stopImageStream();
      _disposeCamera();
      _stopTimer();
      _stopRecordingTimer();
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
    if (_isRecording) {
      _stopRecordingTimer();
      _isRecording = false;
    }
    _stopImageStream();
    // Bersihkan deteksi saat kamera mati
    if (mounted) {
      Provider.of<AiCamProvider>(context, listen: false).clearDetections();
    }
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
        // imageFormatGroup: nv21 WAJIB untuk ML Kit Object Detection di Android
        final controller = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
              ? ImageFormatGroup.nv21
              : ImageFormatGroup.bgra8888,
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

        // Init ML Kit ObjectDetector & start image stream
        final provider = Provider.of<AiCamProvider>(context, listen: false);
        provider.initDetector();
        _startImageStream();

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

  void _startRecordingTimer() {
    _recordingSeconds = 0;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingSeconds++;
        });
      }
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
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

  String get _formattedRecordingTime {
    int m = _recordingSeconds ~/ 60;
    int s = _recordingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Mengambil foto, menyimpan ke galeri, dan mengunggahnya ke UploadScreen.
  Future<void> _takePictureAndUpload() async {
    if (_isCapturing) return;

    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamera belum siap atau tidak tersedia'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // WAJIB: stop image stream sebelum takePicture (tidak bisa berjalan bersamaan)
      _stopImageStream();

      // 1. Ambil foto menggunakan controller kamera
      final XFile photo = await _controller!.takePicture();

      // 2. Simpan foto ke folder Downloads (Web / Chrome) atau Galeri (Mobile)
      try {
        if (kIsWeb) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'uvip_capture_$timestamp.jpg';
          await photo.saveTo(fileName);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Foto diunduh ke folder Downloads & dialihkan ke Upload',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          final hasAccess = await Gal.hasAccess(toAlbum: false);
          if (!hasAccess) {
            await Gal.requestAccess(toAlbum: false);
          }
          await Gal.putImage(photo.path);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Foto tersimpan di galeri & dialihkan ke Upload',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (saveError) {
        debugPrint("Error saving photo: $saveError");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                kIsWeb
                    ? 'Gagal mengunduh ke folder Downloads: $saveError'
                    : 'Gagal menyimpan ke galeri: $saveError',
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      // 3. Trigger upload di UploadProvider dan beralih ke UploadScreen
      if (mounted) {
        final uploadProvider = Provider.of<UploadProvider>(
          context,
          listen: false,
        );
        // Mulai proses upload di background provider
        uploadProvider.uploadPhoto(photo);

        // Beralih ke halaman UploadScreen (Tab 0: Foto)
        if (widget.onSwitchToUpload != null) {
          widget.onSwitchToUpload!(0);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UploadScreen(initialTab: 0),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error taking picture: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
        // Restart image stream setelah capture selesai
        _startImageStream();
      }
    }
  }

  /// Memulai perekaman video kamera
  Future<void> _startVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamera belum siap'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isRecording) return;

    try {
      // WAJIB: stop image stream sebelum startVideoRecording
      _stopImageStream();

      final camera = _cameras![0];
      final provider = Provider.of<AiCamProvider>(context, listen: false);

      await _controller!.startVideoRecording(
        onAvailable: (CameraImage image) {
          if (!mounted || !widget.isActive) return;
          final screenSize = MediaQuery.of(context).size;
          provider.processFrame(image, camera, screenSize);
        },
      );
      setState(() {
        _isRecording = true;
        _isStreaming = true;
      });
      _startRecordingTimer();
    } catch (e) {
      debugPrint("Error starting video recording: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulai perekaman video: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Menghentikan perekaman video dan menampilkan modal preview sebelum upload
  Future<void> _stopVideoRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) {
      return;
    }

    try {
      _stopRecordingTimer();
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isStreaming = false;
      });

      // Restart image stream setelah recording selesai
      _startImageStream();

      if (!mounted) return;

      // Buka modal preview video rekaman
      _showRecordedVideoPreview(videoFile);
    } catch (e) {
      debugPrint("Error stopping video recording: $e");
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyelesaikan rekaman video: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Menampilkan dialog preview video yang baru direkam
  void _showRecordedVideoPreview(XFile videoFile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RecordedVideoPreviewDialog(
        videoFile: videoFile,
        onConfirmUpload: () async {
          // 1. Simpan video ke Galeri (Mobile) atau Downloads (Web)
          try {
            if (kIsWeb) {
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final fileName = 'uvip_video_$timestamp.mp4';
              await videoFile.saveTo(fileName);
            } else {
              final hasAccess = await Gal.hasAccess(toAlbum: false);
              if (!hasAccess) {
                await Gal.requestAccess(toAlbum: false);
              }
              await Gal.putVideo(videoFile.path);
            }
          } catch (saveErr) {
            debugPrint("Error saving video: $saveErr");
          }

          // 2. Upload video via UploadProvider
          if (mounted) {
            final uploadProvider = Provider.of<UploadProvider>(
              context,
              listen: false,
            );
            uploadProvider.uploadVideo(videoFile);

            // 3. Switch ke tab Upload (Tab 1: Video)
            if (widget.onSwitchToUpload != null) {
              widget.onSwitchToUpload!(1);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadScreen(initialTab: 1),
                ),
              );
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Video berhasil disimpan & dialihkan ke Upload',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        onCancel: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perekaman video dibatalkan'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  /// Start streaming frame kamera ke ML Kit untuk object detection.
  void _startImageStream() {
    if (_isStreaming) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final camera = _cameras![0];
    final provider = Provider.of<AiCamProvider>(context, listen: false);

    controller.startImageStream((CameraImage image) {
      // Gunakan ukuran layar saat ini sebagai target mapping
      if (!mounted || !widget.isActive) return;
      final screenSize = MediaQuery.of(context).size;
      provider.processFrame(image, camera, screenSize);
    });
    _isStreaming = true;
  }

  /// Stop image stream.
  void _stopImageStream() {
    if (!_isStreaming) return;
    try {
      _controller?.stopImageStream();
    } catch (e) {
      debugPrint('Error stopping image stream: $e');
    }
    _isStreaming = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _stopRecordingTimer();
    _stopImageStream();
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
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: 100,
                        height: 100 / _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
          ),

          // ─── Bounding Box Overlay (ML Kit Object Detection) ───
          if (_controller != null && _controller!.value.isInitialized)
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

                  // Sub-top Row (Live timer & Location / Recording Badge)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Recording Badge or Live Badge
                      if (_isRecording)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'REC $_formattedRecordingTime',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
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
                        child: const Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppTheme.primaryColor,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
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

                  // Bottom Controls (Mode Switcher & Shutter Capture Button)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 80.0,
                      ), // Above bottom nav
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mode Switcher (Foto vs Video)
                          if (!_isRecording) ...[
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _mode = CameraMode.photo;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _mode == CameraMode.photo
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        'FOTO',
                                        style: TextStyle(
                                          color: _mode == CameraMode.photo
                                              ? Colors.black87
                                              : Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _mode = CameraMode.video;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _mode == CameraMode.video
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        'VIDEO',
                                        style: TextStyle(
                                          color: _mode == CameraMode.video
                                              ? Colors.black87
                                              : Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Shutter / Record Button
                          GestureDetector(
                            onTap: _isCapturing
                                ? null
                                : () {
                                    if (_mode == CameraMode.photo) {
                                      _takePictureAndUpload();
                                    } else {
                                      if (_isRecording) {
                                        _stopVideoRecording();
                                      } else {
                                        _startVideoRecording();
                                      }
                                    }
                                  },
                            child: Container(
                              width: 76,
                              height: 76,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isRecording
                                      ? Colors.redAccent
                                      : Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isRecording
                                      ? Colors.redAccent.withValues(alpha: 0.2)
                                      : (_isCapturing
                                            ? Colors.white.withValues(
                                                alpha: 0.7,
                                              )
                                            : (_mode == CameraMode.photo
                                                  ? Colors.white
                                                  : Colors.redAccent)),
                                ),
                                child: Center(
                                  child: _isCapturing
                                      ? const SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppTheme.primaryColor,
                                                ),
                                          ),
                                        )
                                      : (_mode == CameraMode.photo
                                            ? const Icon(
                                                Icons.camera_alt,
                                                color: AppTheme.primaryColor,
                                                size: 32,
                                              )
                                            : (_isRecording
                                                  ? Container(
                                                      width: 28,
                                                      height: 28,
                                                      decoration: BoxDecoration(
                                                        color: Colors.redAccent,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.videocam_rounded,
                                                      color: Colors.white,
                                                      size: 32,
                                                    ))),
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
