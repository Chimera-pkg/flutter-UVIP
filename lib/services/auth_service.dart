import 'package:dio/dio.dart';
import 'package:uvip/core/network/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient.instance;

  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> register(
    String name,
    String email,
    String password, {
    String role = 'surveyor',
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateAvatar(String filePath) async {
    try {
      final fileName = filePath.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      try {
        final response = await _dio.patch(
          '/users/me/avatar',
          data: formData,
        );
        return response;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          final fallbackFormData = FormData.fromMap({
            'file': await MultipartFile.fromFile(
              filePath,
              filename: fileName,
            ),
          });
          return await _dio.patch(
            '/user/me/avatar',
            data: fallbackFormData,
          );
        }
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }
}
