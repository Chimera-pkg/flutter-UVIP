import 'package:flutter/material.dart';

class StreetPhotoLocationModel {
  final String id;
  final String originalFilename;
  final double latitude;
  final double longitude;
  final double? uviScore;
  final String? streetName;

  StreetPhotoLocationModel({
    required this.id,
    required this.originalFilename,
    required this.latitude,
    required this.longitude,
    this.uviScore,
    this.streetName,
  });

  factory StreetPhotoLocationModel.fromJson(Map<String, dynamic> json) {
    return StreetPhotoLocationModel(
      id: json['id']?.toString() ?? '',
      originalFilename: json['original_filename']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']) ?? 0.0,
      longitude: _parseDouble(json['longitude']) ?? 0.0,
      uviScore: _parseDouble(json['uvi_score']),
      streetName: json['street_name']?.toString(),
    );
  }

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  /// Normalisasi skor ke rentang 0.0 - 1.0 jika berada dalam skala 10 atau 100
  double? get normalizedUviScore {
    if (uviScore == null) return null;
    if (uviScore! < 0.0) return uviScore;
    if (uviScore! > 10.0) return uviScore! / 100.0;
    if (uviScore! > 1.0) return uviScore! / 10.0;
    return uviScore;
  }

  /// Warna marker sesuai standar kategori PVI/UVI di aplikasi
  Color get markerColor {
    final norm = normalizedUviScore;
    if (norm == null || norm < 0.0) {
      return const Color(0xFFC62828); // Level 1: Sangat rendah
    }
    if (norm < 0.0492) {
      return const Color(0xFFE53935); // Level 2: Rendah
    }
    if (norm < 0.1704) {
      return const Color(0xFFFF7043); // Level 3: Cenderung rendah
    }
    if (norm < 0.2917) {
      return const Color(0xFFFFA000); // Level 4: Sedang
    }
    if (norm < 0.4130) {
      return const Color(0xFF4CAF50); // Level 5: Cenderung tinggi
    }
    if (norm < 0.5343) {
      return const Color(0xFF00BFA5); // Level 6: Tinggi
    }
    return const Color(0xFF02BDDB); // Level 7: Sangat tinggi
  }

  /// Label kategori UVI
  String get uviCategory {
    final norm = normalizedUviScore;
    if (norm == null || norm < 0.0) return 'Sangat rendah';
    if (norm < 0.0492) return 'Rendah';
    if (norm < 0.1704) return 'Cenderung rendah';
    if (norm < 0.2917) return 'Sedang';
    if (norm < 0.4130) return 'Cenderung tinggi';
    if (norm < 0.5343) return 'Tinggi';
    return 'Sangat tinggi';
  }

  bool get isVideo {
    final lower = originalFilename.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv');
  }
}
