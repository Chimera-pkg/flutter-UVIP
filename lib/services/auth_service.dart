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
    String role = 'admin',
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
}
