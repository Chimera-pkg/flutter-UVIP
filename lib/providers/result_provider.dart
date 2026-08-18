import 'package:flutter/material.dart';

class ShapFactor {
  final String name;
  final double value;

  ShapFactor({required this.name, required this.value});
}

/// [ResultProvider] mengelola state dan data untuk halaman Hasil Segmentasi (ResultScreen).
/// Mengontrol toggle tab ("Bidang" / "Garis Kontur") dan menyimpan data dummy 
/// untuk skor prediksi, faktor SHAP, dan info lokasi.
class ResultProvider with ChangeNotifier {
  bool _isBidangActive = true;
  bool get isBidangActive => _isBidangActive;

  void toggleTab(bool isBidang) {
    _isBidangActive = isBidang;
    notifyListeners();
  }

  // Mock Data: Skor Prediksi
  final Map<String, dynamic> predictionScores = {
    'UVI': 7.82,
    'Safety': 7.45,
    'Beauty': 8.12,
    'Comfort': 7.68,
    'GVI': '32.4%',
  };

  // Mock Data: Faktor Positif
  final List<ShapFactor> positiveFactors = [
    ShapFactor(name: 'Cakupan Vegetasi', value: 0.42),
    ShapFactor(name: 'Lebar Trotoar', value: 0.31),
    ShapFactor(name: 'Keterbukaan Langit', value: 0.18),
  ];

  // Mock Data: Faktor Negatif
  final List<ShapFactor> negativeFactors = [
    ShapFactor(name: 'Kepadatan Reklame', value: -0.35),
    ShapFactor(name: 'Kepadatan Kendaraan', value: -0.21),
    ShapFactor(name: 'Bangunan Tinggi', value: -0.15),
  ];

  // Mock Data: Informasi Lokasi
  final Map<String, String> locationInfo = {
    'address': 'Jl. Ijen',
    'city': 'Klojen, Malang',
    'date': '16 Juni 2026',
    'time': '10:24 WIB',
    'coordinates': '-7.9792, 112.6301',
    'accuracy': 'Akurasi GPS: 4.2 m',
  };
}
