import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uvip/models/street_photo_model.dart';
import 'package:uvip/models/street_video_model.dart';
import 'package:uvip/services/upload_service.dart';

class UploadProvider with ChangeNotifier {
  final UploadService _uploadService = UploadService();

  List<StreetPhotoModel> _uploadedPhotos = [];
  List<StreetPhotoModel> get uploadedPhotos => _uploadedPhotos;

  List<StreetVideoModel> _uploadedVideos = [];
  List<StreetVideoModel> get uploadedVideos => _uploadedVideos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Pagination for photos
  int _photoCurrentPage = 1;
  int _photoTotalPages = 1;
  bool _isFetchingMorePhotos = false;
  bool get isFetchingMorePhotos => _isFetchingMorePhotos;
  final int _photoSize = 10;
  int _totalPhotoData = 0;
  int get totalPhotoData => _totalPhotoData;

  // Pagination for videos
  int _videoCurrentPage = 1;
  int _videoTotalPages = 1;
  bool _isFetchingMoreVideos = false;
  bool get isFetchingMoreVideos => _isFetchingMoreVideos;
  final int _videoSize = 10;
  int _totalVideoData = 0;
  int get totalVideoData => _totalVideoData;

  // ===================== PHOTOS =====================

  Future<void> fetchStreetPhotos({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (_photoCurrentPage >= _photoTotalPages || _isFetchingMorePhotos) return;
      _isFetchingMorePhotos = true;
      _photoCurrentPage++;
      notifyListeners();
    } else {
      _isLoading = true;
      _photoCurrentPage = 1;
      _uploadedPhotos.clear();
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _uploadService.getStreetPhotos(page: _photoCurrentPage, size: _photoSize);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          _photoTotalPages = data['total_pages'] ?? 1;
          _totalPhotoData = data['total_data'] ?? 0;
          final List<dynamic> listData = data['data'] ?? [];
          final newPhotos = listData.map((json) => StreetPhotoModel.fromJson(json)).toList();
          _uploadedPhotos.addAll(newPhotos);
        } else if (data is List) {
          final newPhotos = data.map((json) => StreetPhotoModel.fromJson(json)).toList();
          _uploadedPhotos.addAll(newPhotos);
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load photos: $e';
      if (isLoadMore) {
        _photoCurrentPage--;
      }
    } finally {
      if (isLoadMore) {
        _isFetchingMorePhotos = false;
      } else {
        _isLoading = false;
      }
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
      String filename = file.name.isNotEmpty
          ? file.name
          : 'uvip_${DateTime.now().millisecondsSinceEpoch}.jpg';
      if (!filename.contains('.')) {
        filename = '$filename.jpg';
      }

      final multipartFile = MultipartFile.fromBytes(bytes, filename: filename);

      final response = await _uploadService.uploadStreetPhoto(
        multipartFile,
        onSendProgress: (sent, total) {
          if (total > 0) {
            _uploadProgress = sent / total;
            notifyListeners();
          }
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
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('detail')) {
          _errorMessage = 'Upload error: ${data['detail']}';
        } else if (data is Map && data.containsKey('message')) {
          _errorMessage = 'Upload error: ${data['message']}';
        } else if (data != null) {
          _errorMessage = 'Upload error (${e.response?.statusCode}): $data';
        } else {
          _errorMessage = 'Upload error: ${e.message}';
        }
      } else {
        _errorMessage = 'Upload error: $e';
      }
      return false;
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  Future<bool> deletePhoto(String photoId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _uploadService.deleteStreetPhoto(photoId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (_selectedPhoto?.id == photoId) {
          _selectedPhoto = null;
        }
        await fetchStreetPhotos();
        return true;
      } else {
        _errorMessage = 'Gagal menghapus foto: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('detail')) {
          _errorMessage = 'Gagal menghapus foto: ${data['detail']}';
        } else if (data is Map && data.containsKey('message')) {
          _errorMessage = 'Gagal menghapus foto: ${data['message']}';
        } else if (data != null) {
          _errorMessage =
              'Gagal menghapus foto (${e.response?.statusCode}): $data';
        } else {
          _errorMessage = 'Gagal menghapus foto: ${e.message}';
        }
      } else {
        _errorMessage = 'Gagal menghapus foto: $e';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  // ===================== VIDEOS =====================

  Future<void> fetchStreetVideos({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (_videoCurrentPage >= _videoTotalPages || _isFetchingMoreVideos) return;
      _isFetchingMoreVideos = true;
      _videoCurrentPage++;
      notifyListeners();
    } else {
      _isLoading = true;
      _videoCurrentPage = 1;
      _uploadedVideos.clear();
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _uploadService.getStreetVideos(page: _videoCurrentPage, size: _videoSize);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          _videoTotalPages = data['total_pages'] ?? 1;
          _totalVideoData = data['total_data'] ?? 0;
          final List<dynamic> listData = data['data'] ?? [];
          final newVideos = listData.map((json) => StreetVideoModel.fromJson(json)).toList();
          _uploadedVideos.addAll(newVideos);
        } else if (data is List) {
          final newVideos = data.map((json) => StreetVideoModel.fromJson(json)).toList();
          _uploadedVideos.addAll(newVideos);
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load videos: $e';
      if (isLoadMore) {
        _videoCurrentPage--;
      }
    } finally {
      if (isLoadMore) {
        _isFetchingMoreVideos = false;
      } else {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<bool> uploadVideo(XFile file) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      final bytes = await file.readAsBytes();
      String filename = file.name.isNotEmpty
          ? file.name
          : 'uvip_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      if (!filename.contains('.')) {
        filename = '$filename.mp4';
      }

      final multipartFile = MultipartFile.fromBytes(bytes, filename: filename);

      final response = await _uploadService.uploadStreetVideo(
        multipartFile,
        onSendProgress: (sent, total) {
          if (total > 0) {
            _uploadProgress = sent / total;
            notifyListeners();
          }
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchStreetVideos(); // Refresh video list after success
        return true;
      } else {
        _errorMessage = 'Upload video failed: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('detail')) {
          _errorMessage = 'Upload video error: ${data['detail']}';
        } else if (data is Map && data.containsKey('message')) {
          _errorMessage = 'Upload video error: ${data['message']}';
        } else if (data != null) {
          _errorMessage = 'Upload video error (${e.response?.statusCode}): $data';
        } else {
          _errorMessage = 'Upload video error: ${e.message}';
        }
      } else {
        _errorMessage = 'Upload video error: $e';
      }
      return false;
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  Future<bool> deleteVideo(String videoId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _uploadService.deleteStreetVideo(videoId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (_selectedVideo?.id == videoId) {
          _selectedVideo = null;
        }
        await fetchStreetVideos();
        return true;
      } else {
        _errorMessage = 'Gagal menghapus video: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('detail')) {
          _errorMessage = 'Gagal menghapus video: ${data['detail']}';
        } else if (data is Map && data.containsKey('message')) {
          _errorMessage = 'Gagal menghapus video: ${data['message']}';
        } else if (data != null) {
          _errorMessage =
              'Gagal menghapus video (${e.response?.statusCode}): $data';
        } else {
          _errorMessage = 'Gagal menghapus video: ${e.message}';
        }
      } else {
        _errorMessage = 'Gagal menghapus video: $e';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  StreetVideoModel? _selectedVideo;
  StreetVideoModel? get selectedVideo => _selectedVideo;

  void toggleVideoSelection(StreetVideoModel video) {
    if (_selectedVideo?.id == video.id) {
      _selectedVideo = null;
    } else {
      _selectedVideo = video;
    }
    notifyListeners();
  }

  // ===================== GENERAL =====================

  void removeUploadedFile(int index) {
    _uploadedPhotos.removeAt(index);
    notifyListeners();
  }

  void cancelUpload() {
    _isUploading = false;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
