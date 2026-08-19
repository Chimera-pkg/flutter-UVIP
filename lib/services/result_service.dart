import 'package:dio/dio.dart';
import 'package:uvip/core/network/dio_client.dart';

class ResultService {
  final Dio _dio = DioClient.instance;

  Future<Response> getSegmentationResultByPhoto(String photoId) async {
    try {
      final response = await _dio.get(
        '/segmentation-results/by-photo/$photoId',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
