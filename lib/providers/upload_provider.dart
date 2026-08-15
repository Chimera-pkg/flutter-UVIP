import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uvip/models/street_photo_model.dart';
import 'package:uvip/services/upload_service.dart';

class UploadProvider with ChangeNotifier {
  final UploadService _uploadService = UploadService();

  List<StreetPhotoModel> _uploadedPhotos = [];
  List<StreetPhotoModel> get uploadedPhotos => _uploadedPhotos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStreetPhotos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _uploadService.getStreetPhotos();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _uploadedPhotos = data.map((json) => StreetPhotoModel.fromJson(json)).toList();
      }
    } catch (e) {
      _errorMessage = 'Failed to load photos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadPhoto(XFile file) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      final bytes = await file.readAsBytes();
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: file.name,
      );

      final response = await _uploadService.uploadStreetPhoto(
        multipartFile,
        onSendProgress: (sent, total) {
          _uploadProgress = sent / total;
          notifyListeners();
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchStreetPhotos(); // Refresh list after success
        return true;
      } else {
        _errorMessage = 'Upload failed: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Upload error: $e';
      return false;
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  void removeUploadedFile(int index) {
    // Optional: Add API call to delete if backend supports it
    _uploadedPhotos.removeAt(index);
    notifyListeners();
  }

  void cancelUpload() {
    _isUploading = false;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  StreetPhotoModel? _selectedPhoto;
  StreetPhotoModel? get selectedPhoto => _selectedPhoto;

  void togglePhotoSelection(StreetPhotoModel photo) {
    if (_selectedPhoto?.id == photo.id) {
      _selectedPhoto = null;
    } else {
      _selectedPhoto = photo;
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

