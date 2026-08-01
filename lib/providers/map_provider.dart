import 'package:flutter/material.dart';

class MapProvider with ChangeNotifier {
  // Filter Options
  final List<String> filters = ['UVI', 'Safety', 'Beauty', 'Comfort', 'GVI'];
  String _selectedFilter = 'UVI';

  // Map Coordinates (Klojen, Malang)
  final double latitude = -7.9786;
  final double longitude = 112.6316;

  // Selected Area Summary Data
  final String rataRataUvi = "7.68";
  final String surveyPoints = "64";
  final String luasArea = "2.45";

  // Chart Data (Last 5 days)
  final List<double> chartData = [4.5, 5.2, 2.5, 4.5, 6.8];

  // Getters
  String get selectedFilter => _selectedFilter;

  // Setters
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
}
