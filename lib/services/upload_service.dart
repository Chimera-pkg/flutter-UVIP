import 'package:dio/dio.dart';
import 'package:uvip/core/network/dio_client.dart';

class UploadService {
  final Dio _dio = DioClient.instance;

  Future<Response> getStreetPhotos() async {
    try {
      final response = await _dio.get('/street-photos/');
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
}
