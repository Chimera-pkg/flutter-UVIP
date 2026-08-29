import 'package:dio/dio.dart';
import 'package:uvip/core/network/dio_client.dart';

class UploadService {
  final Dio _dio = DioClient.instance;

  Future<Response> getStreetPhotos({int page = 1, int size = 10}) async {
    try {
      final response = await _dio.get('/street-photos/', queryParameters: {'page': page, 'size': size});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> uploadStreetPhoto(
    MultipartFile file, {
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': file,
        'source': 'mobile_upload',
        'latitude': 0.0,
        'longitude': 0.0,
        'captured_at': DateTime.now().toUtc().toIso8601String(),
        'is_manual_capture': true,
        'is_offline_sync': false,
      });

      final response = await _dio.post(
        '/street-photos/',
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteStreetPhoto(String photoId) async {
    try {
      final response = await _dio.delete('/street-photos/$photoId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getStreetVideos({int page = 1, int size = 10}) async {
    try {
      final response = await _dio.get('/street-videos/', queryParameters: {'page': page, 'size': size});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> uploadStreetVideo(
    MultipartFile file, {
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': file,
        'source': 'mobile_upload',
        'latitude': 0.0,
        'longitude': 0.0,
        'captured_at': DateTime.now().toUtc().toIso8601String(),
        'is_manual_capture': true,
        'is_offline_sync': false,
      });

      final response = await _dio.post(
        '/street-videos/',
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteStreetVideo(String videoId) async {
    try {
      final response = await _dio.delete('/street-videos/$videoId');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
