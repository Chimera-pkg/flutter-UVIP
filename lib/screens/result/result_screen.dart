import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/result_provider.dart';
import 'package:uvip/widgets/result/score_box.dart';
import 'package:uvip/widgets/result/shap_card.dart';
import 'package:uvip/widgets/common/section_header.dart';
import 'package:uvip/models/street_photo_model.dart';

class ResultScreen extends StatefulWidget {
  final StreetPhotoModel photo;
  final bool isVideo;

  const ResultScreen({super.key, required this.photo, this.isVideo = false});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResultProvider>(
        context,
        listen: false,
      ).fetchSegmentationResult(widget.photo.id, isVideo: widget.isVideo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Hasil Segmentasi',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Consumer<ResultProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (provider.segmentationResult == null &&
              provider.videoSegmentationResult == null) {
            return const Center(child: Text('Hasil tidak ditemukan.'));
          }

          String? fullImageUrl;
          if (widget.isVideo) {
            fullImageUrl = provider.videoSegmentationResult?.videoUrl;
          } else {
            fullImageUrl = provider.segmentationResult?.segmentationOverlayUrl;
          }

          if (fullImageUrl == null || fullImageUrl.isEmpty) {
            fullImageUrl = widget.photo.filePath;
          }
          if (fullImageUrl.isNotEmpty && !fullImageUrl.startsWith('http')) {
            final baseUrl = 'http://80.241.214.39';
            fullImageUrl =
                '$baseUrl/${fullImageUrl.startsWith('/') ? fullImageUrl.substring(1) : fullImageUrl}';
          }

          final bool isVideo =
              fullImageUrl.toLowerCase().endsWith('.mp4') ||
              fullImageUrl.toLowerCase().endsWith('.mov');

          return SingleChildScrollView(
            child: Screenshot(
              controller: _screenshotController,
              child: Container(
                color: AppTheme.backgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Image & Legend
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: fullImageUrl.isNotEmpty
                                ? (isVideo
                                      ? _InlineVideoPlayer(
                                          videoUrl: fullImageUrl,
                                        )
                                      : Image.network(
                                          fullImageUrl,
                                          height: 220,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    height: 220,
                                                    width: double.infinity,
                                                    color: Colors.grey.shade300,
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 64,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        ))
                                : Container(
                                    height: 220,
                                    width: double.infinity,
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.image,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                child: Wrap(
                                  spacing: 12.0,
                                  children: [
                                    _buildLegendItem(
                                      Colors.green.shade600,
                                      'Vegetation',
                                    ),
                                    _buildLegendItem(Colors.purple, 'Building'),
                                    _buildLegendItem(Colors.lightBlue, 'Sky'),
                                    _buildLegendItem(Colors.amber, 'Sidewalk'),
                                    _buildLegendItem(
                                      Colors.red.shade400,
                                      'Vehicles',
                                    ),
                                    _buildLegendItem(
                                      Colors.grey.shade700,
                                      'Road',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildUrbanVisualIndexSection(provider),
                    const SizedBox(height: 32),

                    // Skor Prediksi Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Skor Prediksi'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ScoreBox(
                                title: 'Beauty',
                                score:
                                    provider.currentPrediction?.beautyScore
                                        ?.toString() ??
                                    "-",
                                bgColor: Colors.teal.shade400,
                                textColor: Colors.white,
                              ),
                              ScoreBox(
                                title: 'Safety',
                                score:
                                    provider.currentPrediction?.safetyScore
                                        ?.toString() ??
                                    "-",
                                bgColor: Colors.teal.shade400,
                                textColor: Colors.white,
                              ),
                              ScoreBox(
                                title: 'Comfort',
                                score:
                                    provider.currentPrediction?.comfortScore
                                        ?.toString() ??
                                    "-",
                                bgColor: Colors.teal.shade400,
                                textColor: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Faktor Pengaruh (SHAP)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Faktor Pengaruh (SHAP)'),
                          const SizedBox(height: 16),
                          ShapCard(
                            isPositive: true,
                            factors: provider.positiveFactors,
                          ),
                          ShapCard(
                            isPositive: false,
                            factors: provider.negativeFactors,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildVisualEnvironmentIndicators(provider),
                    const SizedBox(height: 32),

                    // Bottom Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          OutlinedButton(
                            onPressed: _downloadReport,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              side: const BorderSide(
                                color: AppTheme.primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Unduh Laporan',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Kembali ke Beranda',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48), // Bottom Padding
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadReport() async {
    try {
      final image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File(
          '${directory.path}/report_${DateTime.now().millisecondsSinceEpoch}.png',
        ).create();
        await imagePath.writeAsBytes(image);

        await Gal.putImage(imagePath.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Laporan berhasil disimpan ke galeri'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan laporan: $e')));
      }
    }
  }

  Widget _buildUrbanVisualIndexSection(ResultProvider provider) {
    final uviScore = provider.currentPrediction?.uviScore ?? 0;
    String uviText = 'Kurang Baik';
    Color uviColor = Colors.red;
    IconData uviIcon = Icons.thumb_down;

    if (uviScore >= 6) {
      uviText = 'Sangat Tinggi';
      uviColor = Colors.green;
      uviIcon = Icons.thumb_up;
    } else if (uviScore >= 3) {
      uviText = 'Cukup';
      uviColor = Colors.orange;
      uviIcon = Icons.thumbs_up_down;
    } else {
      uviText = 'Kurang Baik';
      uviColor = Colors.red;
      uviIcon = Icons.thumb_down;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Urban Visual Index'),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 6,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        provider.currentPrediction?.uviScore?.toString() ?? "-",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(uviIcon, color: uviColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                uviText,
                                style: TextStyle(
                                  color: uviColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Urban Visual Index adalah tingkat visual ruang suatu kota yang memberikan gambaran kualitas visual dari suatu lokasi, nilai ini diperoleh dari pemrosesan gambar jalan menggunakan AI.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, color: Colors.grey),
                const SizedBox(height: 24),
                // Informasi Lokasi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${provider.locationInfo['address']}\n${provider.locationInfo['city']}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${provider.locationInfo['date']}\n${provider.locationInfo['time']}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.map_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Lat/Long\n${provider.locationInfo['coordinates']}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualEnvironmentIndicators(ResultProvider provider) {
    final segResult = provider.currentSegmentation;
    if (segResult == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Visual Environment Indicators'),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildIndicatorRow(
                  icon: Icons.business,
                  title: 'Indeks Visibilitas Bangunan',
                  subtitle: 'Mempengaruhi tingkat keamanan ruang',
                  percentage: segResult.buildingPct?.toDouble() ?? 0.0,
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildIndicatorRow(
                  icon: Icons.park,
                  title: 'Indeks Tutupan Vegetasi',
                  subtitle: 'Menunjukkan tingkat kenyamanan visual',
                  percentage: segResult.vegetationPct?.toDouble() ?? 0.0,
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildIndicatorRow(
                  icon: Icons.cloud_outlined,
                  title: 'Indeks Keterbukaan Langit',
                  subtitle: 'Tingkat pandangan visual pada langit',
                  percentage: segResult.skyVisibilityPct?.toDouble() ?? 0.0,
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildIndicatorRow(
                  icon: Icons.directions_walk,
                  title: 'Indeks Aksesibilitas Area',
                  subtitle: 'Menunjukkan tingkat kemudahan akses',
                  percentage: segResult.walkabilityRatio?.toDouble() ?? 0.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required double percentage,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100, // Assuming 0-100
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.blue,
                  strokeWidth: 4,
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _InlineVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _InlineVideoPlayer({required this.videoUrl});

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Gunakan Uri.parse dan replace '\' dengan '/' untuk jaga-jaga URL Windows/lokal
    String cleanUrl = widget.videoUrl.replaceAll('\\', '/');
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(Uri.encodeFull(cleanUrl)))
          ..initialize()
              .then((_) {
                if (mounted) {
                  setState(() {
                    _isInitialized = true;
                  });
                  _controller.setVolume(
                    0.0,
                  ); // Muted by default so it can autoplay reliably
                  _controller.setLooping(true);
                  _controller.play();
                }
              })
              .catchError((e) {
                debugPrint("Error loading inline video: $e");
              });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 220,
        width: double.infinity,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
      child: Container(
        height: 220,
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
            if (!_controller.value.isPlaying)
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
            // Unmute / Mute indicator
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.setVolume(
                      _controller.value.volume > 0 ? 0.0 : 1.0,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller.value.volume > 0
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
