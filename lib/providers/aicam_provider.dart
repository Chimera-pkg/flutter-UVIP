import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

/// Model untuk objek yang terdeteksi oleh ML Kit, sudah di-map ke koordinat layar.
class DetectedObjectData {
  final Rect rect;
  final String label;
  final double score;
  final Color color;

  DetectedObjectData({
    required this.rect,
    required this.label,
    required this.score,
    required this.color,
  });
}

/// Warna-warna bounding box yang akan digilir setiap objek terdeteksi.
const _boxColors = [
  Colors.purpleAccent,
  Colors.greenAccent,
  Colors.pinkAccent,
  Colors.cyanAccent,
  Colors.orangeAccent,
  Colors.amberAccent,
  Colors.tealAccent,
  Colors.lightBlueAccent,
];

/// [AiCamProvider] mengelola data terkait deteksi kamera AI (*Live Camera*).
/// Provider ini menjalankan ML Kit ObjectDetector secara on-device (offline, gratis)
/// dan memancarkan list bounding box yang sudah di-map ke koordinat layar.
class AiCamProvider with ChangeNotifier {
  // ─── Live Scores (existing) ───
  final double liveUvi = 8.4;
  final double liveBeauty = 7.2;
  final double liveComfort = 6.9;
  final double liveSafety = 8.1;

  // ─── ML Kit Object Detector ───
  ObjectDetector? _objectDetector;
  bool _isProcessing = false;

  // ─── Detected Objects (mapped to screen coords) ───
  List<DetectedObjectData> _detectedObjects = [];
  List<DetectedObjectData> get detectedObjects => _detectedObjects;

  /// Inisialisasi ObjectDetector dengan default model (gratis, offline).
  /// Harus dipanggil sebelum `processFrame()`.
  void initDetector() {
    if (_objectDetector != null) return;

    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects:
          false, // Set false agar mendeteksi semua objek prominen (bukan cuma 5 kategori)
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  /// Proses satu frame kamera. Dipanggil dari `CameraController.startImageStream()`.
  ///
  /// [image] – raw CameraImage dari stream.
  /// [camera] – CameraDescription untuk sensor orientation.
  /// [screenSize] – ukuran area preview kamera di layar (dari LayoutBuilder/MediaQuery).
  Future<void> processFrame(
    CameraImage image,
    CameraDescription camera,
    Size screenSize,
  ) async {
    // Throttle: skip frame jika masih memproses yang sebelumnya
    if (_isProcessing) return;
    if (_objectDetector == null) return;

    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image, camera);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final objects = await _objectDetector!.processImage(inputImage);

      // Map bounding box dari koordinat gambar ke koordinat layar
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final sensorOrientation = camera.sensorOrientation;

      final mapped = <DetectedObjectData>[];
      for (int i = 0; i < objects.length; i++) {
        final obj = objects[i];
        final mappedRect = _mapBoundingBox(
          obj.boundingBox,
          imageSize,
          screenSize,
          sensorOrientation,
          camera.lensDirection,
        );

        // Ambil label dan confidence dari kategori pertama jika ada
        String label = 'Object';
        double score = 0.0;
        if (obj.labels.isNotEmpty) {
          label = obj.labels.first.text;
          score = obj.labels.first.confidence;
        }

        mapped.add(
          DetectedObjectData(
            rect: mappedRect,
            label: label,
            score: score,
            color: _boxColors[i % _boxColors.length],
          ),
        );
      }

      _detectedObjects = mapped;
      notifyListeners();
    } catch (e) {
      debugPrint('ML Kit processFrame error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Konversi CameraImage → InputImage yang dibaca ML Kit.
  /// Android: format NV21. iOS: bgra8888.
  InputImage? _convertCameraImage(CameraImage image, CameraDescription camera) {
    final sensorOrientation = camera.sensorOrientation;

    // Tentukan rotasi berdasarkan sensor orientation
    final InputImageRotation rotation = switch (sensorOrientation) {
      0 => InputImageRotation.rotation0deg,
      90 => InputImageRotation.rotation90deg,
      180 => InputImageRotation.rotation180deg,
      270 => InputImageRotation.rotation270deg,
      _ => InputImageRotation.rotation0deg,
    };

    // Tentukan format gambar secara eksplisit berdasarkan platform
    // Pada Android, ML Kit HANYA mendukung nv21 (atau yv12).
    // Jika plugin kamera me-return yuv420, memaksa format menjadi nv21 akan mencegah crash (ML Kit akan tetap bisa mendeteksi dari Y-plane/grayscale).
    // Pada iOS, format selalu bgra8888.
    final InputImageFormat format =
        defaultTargetPlatform == TargetPlatform.android
        ? InputImageFormat.nv21
        : InputImageFormat.bgra8888;

    // Untuk Android dan iOS, gabungkan semua planes dengan WriteBuffer
    // karena pada versi camera plugin terbaru, data gambar bisa dipisah ke beberapa planes
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  /// Memetakan Rect bounding box dari koordinat gambar kamera ke koordinat layar.
  ///
  /// Kamera Android mengirim gambar dalam orientasi landscape (sensor 90°),
  /// tapi layar HP dalam orientasi portrait. Jadi kita perlu:
  /// 1. Rotate koordinat 90° (swap width/height)
  /// 2. Scale ke ukuran layar
  /// 3. Handle aspect ratio mismatch (crop offset)
  Rect _mapBoundingBox(
    Rect mlKitRect,
    Size imageSize,
    Size screenSize,
    int sensorOrientation,
    CameraLensDirection lensDirection,
  ) {
    // Pada Android, ML Kit otomatis merotasi gambar (karena kita passing rotasi di metadata).
    // Sehingga Rect yang dikembalikan SUDAH dalam koordinat portrait (rotated).
    // Pada iOS, gambar dari camera plugin (bgra8888) biasanya sudah dalam orientasi portrait.
    final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;

    // Tentukan ukuran gambar yang sudah diproses
    final double processedWidth = isAndroid
        ? imageSize.height
        : imageSize.width;
    final double processedHeight = isAndroid
        ? imageSize.width
        : imageSize.height;

    // Scale factor untuk fit gambar ke layar (cover/fill mode)
    final double scaleX = screenSize.width / processedWidth;
    final double scaleY = screenSize.height / processedHeight;
    final double scale = scaleX > scaleY
        ? scaleX
        : scaleY; // Use max for "cover"

    // Offset untuk centering (karena aspect ratio mismatch)
    final double offsetX = (screenSize.width - processedWidth * scale) / 2;
    final double offsetY = (screenSize.height - processedHeight * scale) / 2;

    double left = mlKitRect.left;
    double top = mlKitRect.top;
    double right = mlKitRect.right;
    double bottom = mlKitRect.bottom;

    // Mirror horizontal jika front camera
    if (lensDirection == CameraLensDirection.front) {
      final double temp = left;
      left = processedWidth - right;
      right = processedWidth - temp;
    }

    // Apply scale + offset
    return Rect.fromLTRB(
      left * scale + offsetX,
      top * scale + offsetY,
      right * scale + offsetX,
      bottom * scale + offsetY,
    );
  }

  /// Bersihkan list deteksi (saat kamera dimatikan/tab pindah).
  void clearDetections() {
    _detectedObjects = [];
    notifyListeners();
  }

  /// Dispose ObjectDetector — harus dipanggil saat provider tidak digunakan lagi.
  void disposeDetector() {
    _objectDetector?.close();
    _objectDetector = null;
    _detectedObjects = [];
  }

  @override
  void dispose() {
    disposeDetector();
    super.dispose();
  }
}
