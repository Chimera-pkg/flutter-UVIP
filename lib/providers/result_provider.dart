import 'package:flutter/material.dart';
import 'package:uvip/models/segmentation_result_model.dart';
import 'package:uvip/models/video_segmentation_result_model.dart';
import 'package:uvip/services/result_service.dart';

class ShapFactor {
  final String name;
  final double value;
  final IconData icon;

  ShapFactor({
    required this.name,
    required this.value,
    this.icon = Icons.circle,
  });
}

class ResultProvider with ChangeNotifier {
  final ResultService _resultService = ResultService();

  bool _isBidangActive = true;
  bool get isBidangActive => _isBidangActive;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SegmentationResultModel? _segmentationResult;
  SegmentationResultModel? get segmentationResult => _segmentationResult;

  VideoSegmentationResultModel? _videoSegmentationResult;
  VideoSegmentationResultModel? get videoSegmentationResult =>
      _videoSegmentationResult;

  SegmentationResultModel? get currentSegmentation =>
      _segmentationResult ?? _videoSegmentationResult?.segmentation;

  PredictionModel? get currentPrediction =>
      _segmentationResult?.prediction ?? _videoSegmentationResult?.prediction;

  void toggleTab(bool isBidang) {
    _isBidangActive = isBidang;
    notifyListeners();
  }

  Future<void> fetchSegmentationResult(
    String photoId, {
    bool isVideo = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isVideo) {
        final response = await _resultService.getVideoSegmentationResultByPhoto(
          photoId,
        );
        if (response.statusCode == 200) {
          _videoSegmentationResult = VideoSegmentationResultModel.fromJson(
            response.data,
          );
        } else {
          _errorMessage = 'Gagal memuat hasil segmentasi video.';
        }
      } else {
        final response = await _resultService.getSegmentationResultByPhoto(
          photoId,
        );
        if (response.statusCode == 200) {
          _segmentationResult = SegmentationResultModel.fromJson(response.data);
        } else {
          _errorMessage = 'Gagal memuat hasil segmentasi.';
        }
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ShapFactor> get positiveFactors => [
    ShapFactor(
      name: 'Cakupan Vegetasi',
      value: currentSegmentation?.greenCoveragePct?.toDouble() ??
          currentSegmentation?.vegetationPct?.toDouble() ??
          0,
      icon: Icons.eco_outlined,
    ),
    ShapFactor(
      name: 'Kepadatan Bangunan',
      value: currentSegmentation?.buildingCoveragePct?.toDouble() ??
          currentSegmentation?.buildingPct?.toDouble() ??
          0,
      icon: Icons.apartment,
    ),
    ShapFactor(
      name: 'Lebar Trotoar',
      value: currentSegmentation?.sidewalkPct?.toDouble() ?? 0,
      icon: Icons.alt_route,
    ),
    ShapFactor(
      name: 'Kondisi Langit Terbuka',
      value: currentSegmentation?.skyVisibilityPct?.toDouble() ??
          currentSegmentation?.skyPct?.toDouble() ??
          0,
      icon: Icons.wb_sunny_outlined,
    ),
  ];

  List<ShapFactor> get negativeFactors => [
    ShapFactor(
      name: 'Kepadatan Reklame',
      value: currentSegmentation?.signagePct?.toDouble() ?? 0,
      icon: Icons.ad_units_outlined,
    ),
    ShapFactor(
      name: 'Kepadatan Kendaraan',
      value: currentSegmentation?.vehiclePct?.toDouble() ?? 0,
      icon: Icons.directions_car_outlined,
    ),
  ];

  Map<String, String> get locationInfo {
    String dateStr = '';
    String timeStr = '';
    final createdAt =
        _segmentationResult?.createdAt ?? _videoSegmentationResult?.createdAt;

    if (createdAt != null && createdAt.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(createdAt).toLocal();
        const months = [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];
        dateStr =
            '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        timeStr = '$hour:$minute WIB';
      } catch (_) {
        dateStr = createdAt;
      }
    }

    return {
      'address': 'Jl. Ijen',
      'city': 'Klojen, Malang',
      'date': dateStr.isNotEmpty ? dateStr : '5 Oktober 2024',
      'time': timeStr.isNotEmpty ? timeStr : '18:27 WIB',
      'coordinates': '-7.9792, 112.6301',
      'accuracy': 'Akurasi GPS: 4.2 m',
    };
  }
}
