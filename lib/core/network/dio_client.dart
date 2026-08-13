import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl:
                'http://103.92.214.110:8001', // Note: use 10.0.2.2 for Android Emulator if 127.0.0.1 fails
            // baseUrl:
            //     'http://10.0.2.2:8000', // Note: use 10.0.2.2 for Android Emulator if 127.0.0.1 fails
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('access_token');
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              return handler.next(options);
            },
          ),
        );

  static Dio get instance => _dio;
}
