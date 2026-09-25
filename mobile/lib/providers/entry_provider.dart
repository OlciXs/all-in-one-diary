import 'dart:convert';
import 'package:flutter/foundation.dart'; // Obsługa kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Obsługa XFile
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

  List<Entry> getEntriesByCategoryId(int categoryId) {
    return _entries.where((entry) => entry.categoryId == categoryId).toList();
  }

  /// Czyszczenie wpisów powiązanych z usuniętą kategorią ze stanu lokalnego
  void removeEntriesByCategoryId(int categoryId) {
    _entries.removeWhere((entry) => entry.categoryId == categoryId);
    notifyListeners();
  }

  Future<void> fetchEntries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final token = await _storageService.getToken();
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/entries'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _entries = data.map((json) => Entry.fromJson(json)).toList();
      } else {
        _errorMessage = 'Nie udało się pobrać wpisów';
      }
    } catch (e) {
      _errorMessage = 'Błąd połączenia z serwerem';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEntry({
    required String title,
    String? content,
    required DateTime startDate,
    DateTime? endDate,
    bool isAllDay = true,
    required int categoryId,
    XFile? photoFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();


      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/entries'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Dodajemy pola tekstowe
      request.fields['title'] = title;
      if (content != null) request.fields['content'] = content;
      request.fields['startDate'] = startDate.toIso8601String();
      if (endDate != null) request.fields['endDate'] = endDate.toIso8601String();
      request.fields['isAllDay'] = isAllDay.toString();
      request.fields['categoryId'] = categoryId.toString();

      // Hybrydowa obsługa pliku
      if (photoFile != null) {
        if (kIsWeb) {
          // Na Webie pobieramy bajty obrazu
          final bytes = await photoFile.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'photo',
              bytes,
              filename: photoFile.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'photo',
              photoFile.path,
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        await fetchEntries();
        return true;
      } else {
        _errorMessage = 'Błąd podczas zapisywania wpisu: ${response.body}';
      }
    } catch (e) {
      _errorMessage = 'Błąd połączenia z serwerem: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// Metoda do usuwania pojedynczego wpisu po jego ID
  Future<bool> deleteEntry(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/entries/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _entries.removeWhere((entry) => entry.id == id);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Nie udało się usunąć wpisu';
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