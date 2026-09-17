import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uvip/main.dart';
import 'package:uvip/providers/auth_provider.dart';
import 'package:uvip/screens/auth/login_screen.dart';

class DioClient {
  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: 'http://80.241.214.39',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Accept': 'application/json'},
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
            onError: (DioException e, handler) async {
              if (e.response?.statusCode == 401) {
                if (navigatorKey.currentContext != null) {
                  await Provider.of<AuthProvider>(
                    navigatorKey.currentContext!,
                    listen: false,
                  ).logout();

                  Navigator.pushAndRemoveUntil(
                    navigatorKey.currentContext!,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                } else {
                  // Fallback
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('access_token');
                }
              }
              return handler.next(e);
            },
          ),
        );

  static Dio get instance => _dio;
}
