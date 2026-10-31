import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uvip/models/street_photo_location_model.dart';
import 'package:uvip/services/upload_service.dart';

/// [MapProvider] mengelola state untuk MapAnalysisScreen.
/// Menyimpan informasi:
/// - Koordinat pusat peta (latitude, longitude)
/// - Filter map yang sedang aktif (UVI, Safety, dsb.)
/// - Data summary terkait area yang dipilih di peta
/// - Titik-titik lokasi foto dari API street-photos/locations
class MapProvider with ChangeNotifier {
  final UploadService _uploadService = UploadService();

  // Filter Options
  final List<String> filters = ['UVI', 'Safety', 'Beauty', 'Comfort', 'GVI'];
  String _selectedFilter = 'UVI';

  // Map Coordinates & Location
  double latitude = -7.9786;
  double longitude = 112.6316;
  String locationName = 'Klojen, Malang';
  bool isLocationLoaded = false;
  bool isLoadingLocation = false;

  // Street Photo Locations from API
  List<StreetPhotoLocationModel> _photoLocations = [];
  List<StreetPhotoLocationModel> get photoLocations => _photoLocations;

  bool _isLoadingLocations = false;
  bool get isLoadingLocations => _isLoadingLocations;

  String? _locationsError;
  String? get locationsError => _locationsError;

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

  void updateCoordinates(double lat, double lng, {String? locName}) {
    latitude = lat;
    longitude = lng;
    if (locName != null) {
      locationName = locName;
    }
    isLocationLoaded = true;
    notifyListeners();
  }

  Future<void> determinePosition() async {
    if (isLoadingLocation) return;
    isLoadingLocation = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLoadingLocation = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLoadingLocation = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        isLoadingLocation = false;
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      latitude = position.latitude;
      longitude = position.longitude;

      try {
        List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          String locality = place.subLocality?.isNotEmpty == true
              ? place.subLocality!
              : (place.locality ?? '');
          String city = place.subAdministrativeArea?.isNotEmpty == true
              ? place.subAdministrativeArea!
              : (place.administrativeArea ?? '');

          if (locality.isNotEmpty && city.isNotEmpty) {
            locationName = '$locality, $city';
          } else if (locality.isNotEmpty) {
            locationName = locality;
          } else if (city.isNotEmpty) {
            locationName = city;
          } else {
            locationName = place.country ?? 'Unknown Location';
          }
        }
      } catch (e) {
        debugPrint('Error reverse geocoding: $e');
      }

      isLocationLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error determinePosition: $e');
    } finally {
      isLoadingLocation = false;
    }
  }

  Future<void> fetchPhotoLocations({String? projectId}) async {
    _isLoadingLocations = true;
    _locationsError = null;
    notifyListeners();

    try {
      final response = await _uploadService.getStreetPhotoLocations(
        projectId: projectId,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> rawList = [];
        if (response.data is List) {
          rawList = response.data;
        } else if (response.data is Map && response.data['data'] is List) {
          rawList = response.data['data'];
        }

        _photoLocations = rawList
            .map(
              (item) => StreetPhotoLocationModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .where((loc) => loc.latitude != 0.0 || loc.longitude != 0.0)
            .toList();
        debugPrint(
          'Berhasil memuat ${_photoLocations.length} titik lokasi foto.',
        );
      } else {
        _locationsError =
            'Gagal memuat titik lokasi (status: ${response.statusCode})';
      }
    } catch (e) {
      _locationsError = 'Terjadi kesalahan: $e';
      debugPrint('Error fetchPhotoLocations: $e');
    } finally {
      _isLoadingLocations = false;
      notifyListeners();
    }
  }
}
