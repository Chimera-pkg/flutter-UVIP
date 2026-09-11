import 'package:flutter/material.dart';
import 'package:uvip/models/segmentation_result_model.dart';
import 'package:uvip/models/video_segmentation_result_model.dart';
import 'package:uvip/services/result_service.dart';

class ShapFactor {
  final String name;
  final double value;

  ShapFactor({required this.name, required this.value});
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

  // Fallback / Mock Data where API is lacking
  // Map<String, dynamic> get predictionScores {
  //   if (_segmentationResult != null || _videoSegmentationResult != null) {
  //     return {
  //       'UVI': Random().nextDouble(),
  //       'Safety': Random().nextDouble(),
  //       'Beauty': Random().nextDouble(),
  //       'Comfort': Random().nextDouble(),
  //       'GVI': Random().nextDouble(),
  //     };
  //   }
  //   return {
  //     'UVI': Random().nextDouble(),
  //     'Safety': Random().nextDouble(),
  //     'Beauty': Random().nextDouble(),
  //     'Comfort': Random().nextDouble(),
  //     'GVI': Random().nextDouble(),
  //   };
  // }

  List<ShapFactor> get positiveFactors => [
    ShapFactor(
      name: 'Cakupan Vegetasi',
      value: _segmentationResult?.greenCoveragePct?.toDouble() ?? 0,
    ),
    ShapFactor(
      name: 'Lebar Trotoar',
      value: _segmentationResult?.sidewalkPct?.toDouble() ?? 0,
    ),
    ShapFactor(
      name: 'Keterbukaan Langit',
      value: _segmentationResult?.skyVisibilityPct?.toDouble() ?? 0,
    ),
  ];

  List<ShapFactor> get negativeFactors => [
    ShapFactor(
      name: 'Kepadatan Reklame',
      value: -(_segmentationResult?.signagePct?.toDouble() ?? 0),
    ),
    ShapFactor(
      name: 'Kepadatan Kendaraan',
      value: -(_segmentationResult?.vehiclePct?.toDouble() ?? 0),
    ),
    ShapFactor(
      name: 'Bangunan Tinggi',
      value: -(_segmentationResult?.buildingCoveragePct?.toDouble() ?? 0),
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
        timeStr = '$hour:$minute';
      } catch (_) {
        dateStr = createdAt;
      }
    }

    return {
      'address': 'Jl. Ijen',
      'city': 'Klojen, Malang',
      'date': dateStr,
      'time': timeStr,
      'coordinates': '-7.9792, 112.6301',
      'accuracy': 'Akurasi GPS: 4.2 m',
    };
  }
}
