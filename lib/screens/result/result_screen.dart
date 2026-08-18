import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvip/core/theme/app_theme.dart';
import 'package:uvip/providers/result_provider.dart';
import 'package:uvip/widgets/result/score_box.dart';
import 'package:uvip/widgets/result/shap_card.dart';
import 'package:uvip/widgets/common/section_header.dart';
import 'package:uvip/models/street_photo_model.dart';

class ResultScreen extends StatefulWidget {
  final StreetPhotoModel photo;

  const ResultScreen({super.key, required this.photo});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResultProvider>(
        context,
        listen: false,
      ).fetchSegmentationResult(widget.photo.id);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black87),
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

          if (provider.segmentationResult == null) {
            return const Center(child: Text('Hasil tidak ditemukan.'));
          }

          String? fullImageUrl = widget.photo.filePath;
          if (fullImageUrl.isNotEmpty && !fullImageUrl.startsWith('http')) {
            final baseUrl = 'http://103.92.214.110:8001';
            fullImageUrl =
                '$baseUrl/${fullImageUrl.startsWith('/') ? fullImageUrl.substring(1) : fullImageUrl}';
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Toggle Tab (Bidang / Garis Kontur)
                _buildToggle(context, provider),
                const SizedBox(height: 24),

                // Main Image & Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: fullImageUrl.isNotEmpty
                            ? Image.network(
                                fullImageUrl,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
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
                              )
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
                                _buildLegendItem(Colors.grey.shade700, 'Road'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ScoreBox(
                            title: 'UVI',
                            score: provider.predictionScores['UVI'].toString(),
                            bgColor: Colors.lime.shade200,
                            textColor: Colors.lime.shade800,
                          ),
                          ScoreBox(
                            title: 'Safety',
                            score: provider.predictionScores['Safety']
                                .toString(),
                            bgColor: Colors.purple.shade100,
                            textColor: Colors.purple.shade800,
                          ),
                          ScoreBox(
                            title: 'Beauty',
                            score: provider.predictionScores['Beauty']
                                .toString(),
                            bgColor: Colors.pink.shade100,
                            textColor: Colors.red.shade700,
                          ),
                          ScoreBox(
                            title: 'Comfort',
                            score: provider.predictionScores['Comfort']
                                .toString(),
                            bgColor: Colors.orange.shade100,
                            textColor: Colors.orange.shade800,
                          ),
                          ScoreBox(
                            title: 'GVI',
                            score: provider.predictionScores['GVI'],
                            bgColor: Colors.green.shade200,
                            textColor: Colors.green.shade800,
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

                // Informasi Lokasi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Informasi Lokasi'),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppTheme.primaryColor,
                            size: 36,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.locationInfo['address']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  provider.locationInfo['city']!,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.calendar_month,
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.locationInfo['date']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  provider.locationInfo['time']!,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.compare_arrows_outlined,
                            color: AppTheme.primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            provider.locationInfo['coordinates']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            provider.locationInfo['accuracy']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48), // Bottom Padding
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggle(BuildContext context, ResultProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => provider.toggleTab(true),
              child: Container(
                decoration: BoxDecoration(
                  color: provider.isBidangActive
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(7.0),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Bidang',
                  style: TextStyle(
                    color: provider.isBidangActive
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => provider.toggleTab(false),
              child: Container(
                decoration: BoxDecoration(
                  color: !provider.isBidangActive
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(7.0),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Garis Kontur',
                  style: TextStyle(
                    color: !provider.isBidangActive
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
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
