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
import 'package:uvip/models/street_video_model.dart';

class ResultScreen extends StatefulWidget {
  final StreetPhotoModel? photo;
  final StreetVideoModel? video;
  final bool isVideo;

  const ResultScreen({super.key, this.photo, this.video, this.isVideo = false});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.isVideo ? widget.video!.id : widget.photo!.id;
      Provider.of<ResultProvider>(
        context,
        listen: false,
      ).fetchSegmentationResult(id, isVideo: widget.isVideo);
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
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined, color: Colors.black87),
            onPressed: _downloadReport,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
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
          String? originalUrl;
          if (widget.isVideo) {
            fullImageUrl = provider.videoSegmentationResult?.videoUrl;
            originalUrl = widget.video!.filePath;
          } else {
            fullImageUrl = provider.segmentationResult?.segmentationOverlayUrl;
            originalUrl = provider.segmentationResult?.privacyMaskedUrl;
          }

          if (fullImageUrl == null || fullImageUrl.isEmpty) {
            fullImageUrl = widget.isVideo
                ? widget.video!.filePath
                : widget.photo!.filePath;
          }
          if (fullImageUrl.isNotEmpty && !fullImageUrl.startsWith('http')) {
            const baseUrl =
                'https://auctions-chemicals-latitude-typing.trycloudflare.com';
            fullImageUrl =
                '$baseUrl/${fullImageUrl.startsWith('/') ? fullImageUrl.substring(1) : fullImageUrl}';
          }

          if (originalUrl == null || originalUrl.isEmpty) {
            originalUrl = widget.isVideo
                ? widget.video!.filePath
                : widget.photo!.filePath;
          }
          if (originalUrl.isNotEmpty && !originalUrl.startsWith('http')) {
            const baseUrl =
                'https://auctions-chemicals-latitude-typing.trycloudflare.com';
            originalUrl =
                '$baseUrl/${originalUrl.startsWith('/') ? originalUrl.substring(1) : originalUrl}';
          }

          final String projectName = widget.isVideo
              ? (provider.videoSegmentationResult?.project?.name ?? '-')
              : (provider.segmentationResult?.project?.name ?? '-');

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
                    // Metadata Card with Original Image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.teal.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.folder_outlined,
                                          color: Colors.teal,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Proyek',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              projectName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.teal.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.image_outlined,
                                          color: Colors.teal,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Nama File',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              widget.isVideo
                                                  ? widget
                                                        .video!
                                                        .originalFilename
                                                  : widget
                                                        .photo!
                                                        .originalFilename,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: originalUrl.isNotEmpty
                                  ? (isVideo
                                        ? _InlineVideoPlayer(
                                            videoUrl: originalUrl,
                                          )
                                        : Image.network(
                                            originalUrl,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      height: 200,
                                                      width: double.infinity,
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        size: 64,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                          ))
                                  : Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.image,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Segmentasi AI Header
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: SectionHeader(title: 'Segmentasi AI'),
                    ),
                    const SizedBox(height: 16),

                    // Segmentasi AI Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Foto Overlay AI',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: fullImageUrl.isNotEmpty
                                  ? (isVideo
                                        ? _InlineVideoPlayer(
                                            videoUrl: fullImageUrl,
                                          )
                                        : Image.network(
                                            fullImageUrl,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      height: 200,
                                                      width: double.infinity,
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        size: 64,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                          ))
                                  : Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.image,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            // Legend Grid
                            GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 3.5,
                              children: [
                                _buildLegendItem(
                                  Colors.green.shade700,
                                  'Vegetation',
                                ),
                                _buildLegendItem(Colors.blue, 'Sky'),
                                _buildLegendItem(
                                  Colors.red.shade600,
                                  'Vehicles',
                                ),
                                _buildLegendItem(Colors.purple, 'Building'),
                                _buildLegendItem(Colors.amber, 'Sidewalk'),
                                _buildLegendItem(Colors.grey.shade800, 'Road'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Urban Visual Index Section
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
                            children: [
                              Expanded(
                                child: ScoreBox(
                                  title: 'Beauty',
                                  icon: Icons.auto_awesome,
                                  score:
                                      provider.currentPrediction?.beautyScore
                                          ?.toStringAsFixed(1) ??
                                      "10.0",
                                  bgColor: const Color(0xFFFF3B70),
                                  textColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ScoreBox(
                                  title: 'Safety',
                                  icon: Icons.shield_outlined,
                                  score:
                                      provider.currentPrediction?.safetyScore
                                          ?.toStringAsFixed(1) ??
                                      "10.0",
                                  bgColor: const Color(0xFF00CBA9),
                                  textColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ScoreBox(
                                  title: 'Comfort',
                                  icon: Icons.weekend_outlined,
                                  score:
                                      provider.currentPrediction?.comfortScore
                                          ?.toStringAsFixed(1) ??
                                      "10.0",
                                  bgColor: const Color(0xFFFF9E1B),
                                  textColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Faktor Pengaruh UVI Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Faktor Pengaruh UVI'),
                          const SizedBox(height: 4),
                          const Text(
                            'Kombinasi faktor positif dan negatif berikut membentuk nilai Urban Visual Index.',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
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

                    // Visual Environment Indicators Section
                    _buildVisualEnvironmentIndicators(provider),
                    const SizedBox(height: 32),

                    // Rekomendasi AI Section (Foto Only)
                    if (!widget.isVideo) ...[
                      _buildRekomendasiAiSection(context, provider),
                      const SizedBox(height: 32),
                    ],

                    // Bottom Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _downloadReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Unduh Laporan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppTheme.primaryColor,
                                width: 1.5,
                              ),
                              foregroundColor: AppTheme.primaryColor,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Kembali ke Beranda',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
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
    final num? rawScore = provider.currentPrediction?.uviScore;
    final double uviScore = rawScore?.toDouble() ?? 0.0;

    String uviDisplay = "1";
    if (rawScore != null) {
      if (uviScore % 1 == 0) {
        uviDisplay = uviScore.toInt().toString();
      } else {
        uviDisplay = uviScore.toString();
      }
    }

    String uviCategory = "Sangat rendah";
    Color uviColor = const Color(0xFFC62828);

    if (rawScore == null || uviScore < 0.0) {
      uviCategory = "Sangat rendah";
      uviColor = const Color(0xFFC62828);
    } else if (uviScore < 0.0492) {
      uviCategory = "Rendah";
      uviColor = const Color(0xFFE53935);
    } else if (uviScore < 0.1704) {
      uviCategory = "Cenderung rendah";
      uviColor = const Color(0xFFFF7043);
    } else if (uviScore < 0.2917) {
      uviCategory = "Sedang";
      uviColor = const Color(0xFFFFA000);
    } else if (uviScore < 0.4130) {
      uviCategory = "Cenderung tinggi";
      uviColor = const Color(0xFF4CAF50);
    } else if (uviScore < 0.5343) {
      uviCategory = "Tinggi";
      uviColor = const Color(0xFF00BFA5);
    } else {
      uviCategory = "Sangat tinggi";
      uviColor = AppTheme.primaryColor;
    }

    // Sentence taken from prediction->llm_generate_response->suggestions[0]
    final suggestions =
        provider.currentPrediction?.llmGenerateResponse?.suggestions;
    final String suggestionText =
        (suggestions != null && suggestions.isNotEmpty)
        ? suggestions.first
        : "Urban Visual Index adalah tingkat visual ruang suatu kota yang memberikan gambaran kualitas visual dari suatu lokasi, nilai ini diperoleh dari pemrosesan gambar jalan menggunakan AI.";

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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: uviColor, width: 6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        uviDisplay,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: uviColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: uviColor, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                uviCategory,
                                style: TextStyle(
                                  color: uviColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            suggestionText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 16),
                const Text(
                  'Informasi Lokasi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${provider.locationInfo['address']}\n${provider.locationInfo['city']}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppTheme.primaryColor,
                            size: 18,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${provider.locationInfo['date']}\n${provider.locationInfo['time']}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.explore_outlined,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Lat/Long\n${provider.locationInfo['coordinates']}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              height: 1.3,
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

    final double buildingPct =
        (segResult.buildingCoveragePct ?? segResult.buildingPct)?.toDouble() ??
        87.4;
    final double vegetationPct =
        (segResult.greenCoveragePct ?? segResult.vegetationPct)?.toDouble() ??
        76.4;
    final double skyPct =
        (segResult.skyVisibilityPct ?? segResult.skyPct)?.toDouble() ?? 12.0;

    double walkabilityPct = 45.7;
    if (segResult.walkabilityRatio != null) {
      final double ratio = segResult.walkabilityRatio!.toDouble();
      walkabilityPct = ratio <= 1.0 ? ratio * 100 : ratio;
    }

    final double commercialPct = (segResult.signagePct?.toDouble() ?? 0.0) > 0
        ? (segResult.signagePct!.toDouble() +
              (segResult.streetFurniturePct?.toDouble() ?? 0.0))
        : 39.8;

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
                  icon: Icons.apartment,
                  title: 'Indeks Visibilitas Bangunan',
                  subtitle: 'Tingkat dominasi bangunan terhadap lanskap',
                  percentage: buildingPct,
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildIndicatorRow(
                  icon: Icons.park_outlined,
                  title: 'Indeks Tutupan Vegetasi',
                  subtitle: 'Proporsi area hijau seperti pohon dan taman',
                  percentage: vegetationPct,
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildIndicatorRow(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Indeks Keterbukaan Langit',
                  subtitle: 'Tingkat keterbukaan ruang langit',
                  percentage: skyPct,
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildIndicatorRow(
                  icon: Icons.directions_walk,
                  title: 'Indeks Aksesibilitas Area',
                  subtitle: 'Tingkat kemudahan akses bagi pejalan kaki',
                  percentage: walkabilityPct,
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildIndicatorRow(
                  icon: Icons.storefront_outlined,
                  title: 'Indeks Komersial Kawasan',
                  subtitle: 'Tingkat aktivitas komersial di area sekitar',
                  percentage: commercialPct,
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
            child: Icon(icon, color: const Color(0xFF1E3A5F), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (percentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF1E3A5F),
                  strokeWidth: 4,
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRekomendasiAiSection(
    BuildContext context,
    ResultProvider provider,
  ) {
    // Sentence taken from prediction->llm_generate_response->suggestions[0]
    final suggestions =
        provider.currentPrediction?.llmGenerateResponse?.suggestions;
    final String suggestionText =
        (suggestions != null && suggestions.isNotEmpty)
        ? suggestions.first
        : "-";

    // Image URL taken from prediction->llm_generate_response->generated_image_url
    final String? rawGeneratedPath =
        provider.currentPrediction?.llmGenerateResponse?.generatedImageUrl;
    String fullGeneratedUrl = '';
    if (rawGeneratedPath != null && rawGeneratedPath.isNotEmpty) {
      if (rawGeneratedPath.startsWith('http')) {
        fullGeneratedUrl = rawGeneratedPath;
      } else {
        final cleanPath = rawGeneratedPath.startsWith('/')
            ? rawGeneratedPath.substring(1)
            : rawGeneratedPath;
        fullGeneratedUrl =
            'https://auctions-chemicals-latitude-typing.trycloudflare.com/$cleanPath';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Rekomendasi AI'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Suggestion row with icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.push_pin,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        suggestionText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Visualisasi prediktif berbasis AI title
                const Text(
                  'Visualisasi prediktif berbasis AI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // Generated Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: fullGeneratedUrl.isNotEmpty
                      ? Image.network(
                          fullGeneratedUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                        )
                      : Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 8),

                // Image caption
                const Text(
                  'Simulasi perbaikan koridor jalan dengan penambahan pohon peneduh dan pelebaran trotoar ramah pejalan kaki.',
                  style: TextStyle(color: Colors.black54, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Button "Lihat Rekomendasi AI"
                OutlinedButton(
                  onPressed: () => _showAdviceModal(context, provider),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Lihat Rekomendasi AI',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAdviceModal(BuildContext context, ResultProvider provider) {
    final advice = provider.currentSegmentation?.llmAdviceResponse?.advice;
    final suggestions =
        provider.currentPrediction?.llmGenerateResponse?.suggestions ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Icon(
                        Icons.auto_awesome,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Rekomendasi & Analisis AI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (advice?.diagnosis != null &&
                      advice!.diagnosis!.isNotEmpty) ...[
                    const Text(
                      'Diagnosis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      advice.diagnosis!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                  ],

                  if (advice != null && advice.rekomendasi.isNotEmpty) ...[
                    const Text(
                      'Tindakan Rekomendasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...advice.rekomendasi.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.peran
                                        .replaceAll('_', ' ')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (item.prioritas != null)
                                  Text(
                                    'Prioritas ${item.prioritas}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.tindakan,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            if (item.dampak != null &&
                                item.dampak!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Dampak: ${item.dampak}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                            if (item.standar != null &&
                                item.standar!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Standar: ${item.standar}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                  ],

                  if (suggestions.isNotEmpty) ...[
                    const Text(
                      'Saran Perbaikan Visual',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...suggestions.map((sug) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                sug,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],

                  if (advice?.caveat != null && advice!.caveat!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.amber.shade900,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              advice.caveat!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.amber.shade900,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
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
    String cleanUrl = widget.videoUrl.replaceAll('\\', '/');
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(Uri.encodeFull(cleanUrl)))
          ..initialize()
              .then((_) {
                if (mounted) {
                  setState(() {
                    _isInitialized = true;
                  });
                  _controller.setVolume(0.0);
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
