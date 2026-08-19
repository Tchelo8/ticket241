import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _user;
  String? _token;
  bool _isLoading = true; // Start true to check initial login state

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() {
    _tryAutoLogin();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('access_token') || !prefs.containsKey('user_data')) {
      _setLoading(false);
      return;
    }

    _token = prefs.getString('access_token');
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      _user = jsonDecode(userDataString);
    }

    _setLoading(false);
    notifyListeners();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _apiService.register(firstName, lastName, email, phone, password);

    if (!response.success) {
      if (response.errors != null) {
        // Validation errors (400)
        throw response.errors!;
      } else {
        // General message error (409, 503, etc.)
        throw response.message ?? 'An unknown error occurred during registration.';
      }
    }
    // Success means OTP was sent, UI will navigate to OTP screen
  }

  Future<void> verifyOtp(String phone, String code) async {
    final response = await _apiService.verifyOtp(phone, code);

    if (response.success && response.data != null) {
      final responseData = response.data!;
      _token = responseData['token'];
      _user = responseData; // The whole response is the user object

      if (_token != null && _user != null) {
        await _saveSession(_token!, _user!); // Save the session
        notifyListeners(); // Notify that auth state has changed
      } else {
        throw 'Token or user data is missing in the server response.';
      }
    } else {
      throw response.message ?? 'An unknown error occurred during OTP verification.';
    }
  }

  Future<void> resendOtp(String phone) async {
     final response = await _apiService.resendOtp(phone);
     if (!response.success) {
       throw response.message ?? 'Failed to resend OTP.';
     }
  }


  Future<void> login(String phone, String password) async {
    final response = await _apiService.login(phone, password);

    if (response.success && response.data != null) {
      final responseData = response.data!;
      _token = responseData['token'];
      _user = responseData; // The whole response is the user object

      if (_token != null && _user != null) {
        await _saveSession(_token!, _user!); // Save the session
        notifyListeners(); // Notify that auth state has changed
      } else {
         throw 'Token or user data is missing in the server response.';
      }
    } else {
       if (response.errors != null) {
        throw response.errors!;
      } else {
        throw response.message ?? 'An unknown error occurred during login.';
      }
    }
  }

  Future<void> forgotPassword(String phone) async {
    final response = await _apiService.forgotPassword(phone);
     if (!response.success) {
       throw response.message ?? 'Failed to process forgot password request.';
     }
  }

  Future<void> _saveSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('user_data', jsonEncode(user));
  }

  Future<void> logout() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_data');

    _token = null;
    _user = null;
    
    _setLoading(false);
    notifyListeners();
  }
}
