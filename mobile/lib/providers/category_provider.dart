import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/secure_storage_service.dart';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

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

  // Tworzenie nowej kategorii
  Future<bool> addCategory(String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name}),
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