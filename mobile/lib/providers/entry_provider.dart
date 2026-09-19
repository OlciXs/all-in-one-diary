import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/entry.dart';
import '../services/secure_storage_service.dart';

class EntryProvider with ChangeNotifier {
  final SecureStorageService _storageService = SecureStorageService();
  final String _baseUrl = 'http://localhost:3000';

  List<Entry> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Entry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filtrowanie wpisów po kategorii lokalnie w pamięci
  List<Entry> getEntriesByCategoryId(int categoryId) {
    return _entries.where((entry) => entry.categoryId == categoryId).toList();
  }

Future<void> fetchEntries() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  final token = await _storageService.getToken();
  if (token == null) {
    debugPrint('❌ [EntryProvider] Brak tokena w pamięci!');
    _isLoading = false;
    notifyListeners();
    return;
  }

  try {
    debugPrint('🚀 [EntryProvider] Wysyłam zapytanie do serwera...');
    final response = await http.get(
      Uri.parse('$_baseUrl/entries'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('📡 [EntryProvider] Status kod: ${response.statusCode}');
    debugPrint('📦 [EntryProvider] Odpowiedź z serwera: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _entries = data.map((json) => Entry.fromJson(json)).toList();
      debugPrint('✅ [EntryProvider] Pobrano ${_entries.length} wpisów.');
    } else {
      _errorMessage = 'Nie udało się pobrać wpisów';
    }
  } catch (e) {
    debugPrint('❌ [EntryProvider] Błąd połączenia/parsowania: $e');
    _errorMessage = 'Błąd połączenia z serwerem';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

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
        await fetchEntries(); // Odświeżamy listę wpisów po dodaniu nowego
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