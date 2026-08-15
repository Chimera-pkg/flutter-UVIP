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

  Future<Response> uploadStreetPhoto(MultipartFile file, {void Function(int, int)? onSendProgress}) async {
    try {
      final formData = FormData.fromMap({
        'file': file,
        'source': 'mobile_upload',
        'latitude': 0,
        'longitude': 0,
        'captured_at': DateTime.now().toUtc().toIso8601String(),
        'mission_id': '',
        'gps_accuracy_m': '',
        'compass_azimuth': '',
        'exif_timestamp': '',
        'is_manual_capture': false,
        'is_offline_sync': true,
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
}
