import 'dart:math';
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
  VideoSegmentationResultModel? get videoSegmentationResult => _videoSegmentationResult;

  void toggleTab(bool isBidang) {
    _isBidangActive = isBidang;
    notifyListeners();
  }

  Future<void> fetchSegmentationResult(String photoId, {bool isVideo = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isVideo) {
        final response = await _resultService.getVideoSegmentationResultByPhoto(photoId);
        if (response.statusCode == 200) {
          _videoSegmentationResult = VideoSegmentationResultModel.fromJson(response.data);
        } else {
          _errorMessage = 'Gagal memuat hasil segmentasi video.';
        }
      } else {
        final response = await _resultService.getSegmentationResultByPhoto(photoId);
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
  Map<String, dynamic> get predictionScores {
    if (_segmentationResult != null || _videoSegmentationResult != null) {
      return {
        'UVI': Random().nextDouble(),
        'Safety': Random().nextDouble(),
        'Beauty': Random().nextDouble(),
        'Comfort': Random().nextDouble(),
        'GVI': Random().nextDouble(),
      };
    }
    return {
      'UVI': Random().nextDouble(),
      'Safety': Random().nextDouble(),
      'Beauty': Random().nextDouble(),
      'Comfort': Random().nextDouble(),
      'GVI': Random().nextDouble(),
    };
  }

  List<ShapFactor> get positiveFactors => [
    ShapFactor(name: 'Cakupan Vegetasi', value: Random().nextDouble()),
    ShapFactor(name: 'Lebar Trotoar', value: Random().nextDouble()),
    ShapFactor(name: 'Keterbukaan Langit', value: Random().nextDouble()),
  ];

  List<ShapFactor> get negativeFactors => [
    ShapFactor(name: 'Kepadatan Reklame', value: -Random().nextDouble()),
    ShapFactor(name: 'Kepadatan Kendaraan', value: -Random().nextDouble()),
    ShapFactor(name: 'Bangunan Tinggi', value: -Random().nextDouble()),
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
