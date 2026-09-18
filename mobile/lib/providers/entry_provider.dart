import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/secure_storage_service.dart';

class EntryProvider with ChangeNotifier {
  final SecureStorageService _storageService = SecureStorageService();
  final String _baseUrl = 'http://localhost:3000';

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> addEntry({
    required String title,
    required String content,
    required int categoryId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/entries'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
          'categoryId': categoryId,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        _errorMessage = 'Błąd podczas zapisywania wpisu';
      }
    } catch (e) {
      _errorMessage = 'Błąd połączenia z serwerem';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}