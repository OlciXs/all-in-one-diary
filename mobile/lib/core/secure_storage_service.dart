import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  // Zapisz token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Pobierz token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Usuń token (Wylogowanie)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}