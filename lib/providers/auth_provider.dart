import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uvip/models/user_model.dart';
import 'package:uvip/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Store the access token for other requests
  String? _accessToken;
  String? get accessToken => _accessToken;

  UserModel? _user;
  UserModel? get user => _user;

  bool _isFetchingMe = false;
  bool get isFetchingMe => _isFetchingMe;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authService.login(email, password);
      _setLoading(false);

      // Assume 200/201 is success
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save token to SharedPreferences
        final data = response.data;
        if (data != null && data['access_token'] != null) {
          _accessToken = data['access_token'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', _accessToken!);

          // Fetch user data after successful login
          await fetchMe();
        }
        return true;
      } else {
        _errorMessage = 'Login failed. Please try again.';
        return false;
      }
    } on DioException catch (e) {
      _setLoading(false);
      _errorMessage =
          e.response?.data?['detail'] ?? e.message ?? 'An error occurred';
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password, {
    String role = 'admin',
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authService.register(
        name,
        email,
        password,
        role: role,
      );
      _setLoading(false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        _errorMessage = 'Registration failed. Please try again.';
        return false;
      }
    } on DioException catch (e) {
      _setLoading(false);
      _errorMessage =
          e.response?.data?['detail'] ?? e.message ?? 'An error occurred';
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<void> fetchMe() async {
    _isFetchingMe = true;
    notifyListeners();

    try {
      final response = await _authService.getMe();
      if (response.statusCode == 200) {
        _user = UserModel.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetching /auth/me: $e');
    } finally {
      _isFetchingMe = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    notifyListeners();
  }
}
