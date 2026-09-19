import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../services/secure_storage_service.dart';

class CategoryProvider with ChangeNotifier {
  final SecureStorageService _storageService = SecureStorageService();
  final String _baseUrl = 'http://localhost:3000';

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Pobieranie kategorii z backendu
  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _categories = data.map((json) => Category.fromJson(json)).toList();
      } else {
        _errorMessage = 'Nie udało się pobrać kategorii';
      }
    } catch (e) {
      _errorMessage = 'Błąd połączenia z serwerem';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Usuwanie kategorii
  Future<bool> deleteCategory(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/categories/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Usuwamy kategorię z lokalnej listy
        _categories.removeWhere((cat) => cat.id == id);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Nie udało się usunąć kategorii';
      }
    } catch (e) {
      _errorMessage = 'Błąd połączenia z serwerem';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // Tworzenie nowej kategorii
  Future<bool> addCategory({
    required String name,
    required Color color,
    required bool hasContent,
    required bool hasPhotos,
    required bool hasDate,
    required bool defaultToCurrentDate,
    required bool allowTimeRange,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      
      final String hexColor =
          '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';

      final response = await http.post(
        Uri.parse('$_baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'color': hexColor,
          'hasContent': hasContent,
          'hasPhotos': hasPhotos,
          'hasDate': hasDate,
          'defaultToCurrentDate': defaultToCurrentDate,
          'allowTimeRange': allowTimeRange,
        }),
      );

      if (response.statusCode == 201) {
        final newCategory = Category.fromJson(jsonDecode(response.body));
        _categories.add(newCategory);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Błąd podczas tworzenia kategorii';
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