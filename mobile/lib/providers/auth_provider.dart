import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../services/secure_storage_service.dart';

class AuthProvider with ChangeNotifier {
  final SecureStorageService _storage = SecureStorageService();

  bool get isAuthenticated => _token != null;

  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- AUTOMATYCZNE LOGOWANIE ---
  Future<bool> tryAutoLogin() async {
    final savedToken = await _storage.getToken();
    if (savedToken == null) {
      return false;
    }

    _token = savedToken;
    notifyListeners();
    return true;
  }

  // --- LOGOWANIE ---
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _token = responseData['access_token'];
        if (_token != null) {
          await _storage.saveToken(_token!);
        }
        _setLoading(false);
        return true;
      } else {
        _handleErrorResponse(responseData);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('BŁĄD LOGOWANIA: $e');
      _errorMessage = 'Brak połączenia z serwerem';
      _setLoading(false);
      return false;
    }
  }

  // --- REJESTRACJA ---
  Future<bool> register({
    required String login,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': login.trim(),
          'email': email.trim(),
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _setLoading(false);
        return true;
      } else {
        _handleErrorResponse(responseData);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('BŁĄD REJESTRACJI: $e');
      _errorMessage = 'Brak połączenia z serwerem';
      _setLoading(false);
      return false;
    }
  }

  // --- WYLOGOWANIE ---
  Future<void> logout() async {
    _token = null;
    await _storage.deleteToken();
    notifyListeners();
  }

  // --- POMOCNICZA METODA DO BŁĘDÓW NESTJS ---
  void _handleErrorResponse(dynamic responseData) {
    if (responseData['message'] is List) {
      _errorMessage = (responseData['message'] as List).join('\n');
    } else {
      _errorMessage = responseData['message'] ?? 'Wystąpił błąd';
    }
  }
}
