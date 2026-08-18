import 'package:flutter/material.dart';
import 'package:uvip/models/segmentation_result_model.dart';
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

  void toggleTab(bool isBidang) {
    _isBidangActive = isBidang;
    notifyListeners();
  }

  Future<void> fetchSegmentationResult(String photoId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _resultService.getSegmentationResultByPhoto(photoId);
      if (response.statusCode == 200) {
        _segmentationResult = SegmentationResultModel.fromJson(response.data);
      } else {
        _errorMessage = 'Gagal memuat hasil segmentasi.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fallback / Mock Data where API is lacking
  Map<String, dynamic> get predictionScores {
    if (_segmentationResult != null) {
      return {
        'UVI': _segmentationResult!.visualClutterIndex.toStringAsFixed(2), // Example mapping
        'Safety': (_segmentationResult!.walkabilityRatio * 10).toStringAsFixed(2), // Example mapping
        'Beauty': (_segmentationResult!.greenCoveragePct).toStringAsFixed(2), // Example mapping
        'Comfort': (_segmentationResult!.skyVisibilityPct).toStringAsFixed(2), // Example mapping
        'GVI': '${_segmentationResult!.greenCoveragePct.toStringAsFixed(1)}%',
      };
    }
    return {
      'UVI': 7.82,
      'Safety': 7.45,
      'Beauty': 8.12,
      'Comfort': 7.68,
      'GVI': '32.4%',
    };
  }

  final List<ShapFactor> positiveFactors = [
    ShapFactor(name: 'Cakupan Vegetasi', value: 0.42),
    ShapFactor(name: 'Lebar Trotoar', value: 0.31),
    ShapFactor(name: 'Keterbukaan Langit', value: 0.18),
  ];

  final List<ShapFactor> negativeFactors = [
    ShapFactor(name: 'Kepadatan Reklame', value: -0.35),
    ShapFactor(name: 'Kepadatan Kendaraan', value: -0.21),
    ShapFactor(name: 'Bangunan Tinggi', value: -0.15),
  ];

  final Map<String, String> locationInfo = {
    'address': 'Jl. Ijen',
    'city': 'Klojen, Malang',
    'date': '16 Juni 2026',
    'time': '10:24 WIB',
    'coordinates': '-7.9792, 112.6301',
    'accuracy': 'Akurasi GPS: 4.2 m',
  };
}
