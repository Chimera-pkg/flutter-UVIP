import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/map_provider.dart';
import 'package:uvip/providers/upload_provider.dart';
import 'package:uvip/screens/upload/upload_screen.dart';
import 'package:uvip/widgets/recorded_video_preview_dialog.dart';
import 'package:uvip/widgets/recorded_photo_preview_dialog.dart';

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
  bool _isFlashOn = false;
  bool _permissionDenied = false;
  bool _isInitializing = false; // Guard agar tidak ada inisialisasi paralel
  bool _isCapturing = false; // Guard saat proses pengambilan foto & simpan

  // Video recording state
  CameraMode _mode = CameraMode.photo;
  bool _isRecording = false;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Hanya init kamera jika tab ini langsung aktif saat pertama kali dibuat
    if (widget.isActive) {
      _initializeCamera();
    }
  }

  @override
  void didUpdateWidget(covariant AiCamScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Respond saat tab visibility berubah
    if (widget.isActive && !oldWidget.isActive) {
      // Tab baru saja jadi aktif → nyalakan kamera & timer
      _initializeCamera();
    } else if (!widget.isActive && oldWidget.isActive) {
      // Tab baru saja jadi tidak aktif → matikan kamera & timer
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

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
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

  /// Mengambil foto dan menampilkan modal preview sebelum upload
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
      // 1. Ambil foto menggunakan controller kamera
      final XFile photo = await _controller!.takePicture();

      if (!mounted) return;

      // Buka modal preview foto tangkapan
      _showRecordedPhotoPreview(photo);
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
      }
    }
  }

  /// Menampilkan dialog preview foto yang baru direkam
  void _showRecordedPhotoPreview(XFile photoFile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RecordedPhotoPreviewDialog(
        photoFile: photoFile,
        onConfirmUpload: (projectId) async {
          // 1. Simpan foto ke folder Downloads (Web / Chrome) atau Galeri (Mobile)
          try {
            if (kIsWeb) {
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final fileName = 'uvip_capture_$timestamp.jpg';
              await photoFile.saveTo(fileName);
            } else {
              final hasAccess = await Gal.hasAccess(toAlbum: false);
              if (!hasAccess) {
                await Gal.requestAccess(toAlbum: false);
              }
              await Gal.putImage(photoFile.path);
            }
          } catch (saveError) {
            debugPrint("Error saving photo: $saveError");
          }

          // 2. Upload foto via UploadProvider
          if (mounted) {
            final uploadProvider = Provider.of<UploadProvider>(
              context,
              listen: false,
            );
            final mapProvider = Provider.of<MapProvider>(
              context,
              listen: false,
            );
            uploadProvider.setCurrentProjectId(projectId);
            uploadProvider.uploadPhoto(
              photoFile,
              latitude: mapProvider.latitude,
              longitude: mapProvider.longitude,
              locationName: mapProvider.locationName,
            );

            // 3. Switch ke tab Upload (Tab 0: Foto)
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

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Foto berhasil disimpan & dialihkan ke Upload',
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
                content: Text('Pengambilan foto dibatalkan'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
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
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
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
      });

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
        onConfirmUpload: (projectId) async {
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
            final mapProvider = Provider.of<MapProvider>(
              context,
              listen: false,
            );
            uploadProvider.setCurrentProjectId(projectId);
            uploadProvider.uploadVideo(
              videoFile,
              latitude: mapProvider.latitude,
              longitude: mapProvider.longitude,
              locationName: mapProvider.locationName,
            );

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _stopRecordingTimer();
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
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final previewSize = _controller!.value.previewSize;
                      if (previewSize == null) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        );
                      }

                      final isLandscape =
                          constraints.maxWidth > constraints.maxHeight;
                      final previewWidth = isLandscape
                          ? previewSize.width
                          : previewSize.height;
                      final previewHeight = isLandscape
                          ? previewSize.height
                          : previewSize.width;

                      return SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: ClipRect(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: previewWidth,
                              height: previewHeight,
                              child: CameraPreview(_controller!),
                            ),
                          ),
                        ),
                      );
                    },
                  )
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
                      const SizedBox(),
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
}
