import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  // Dedykowana opcja dla Web
  static const _webOptions = WebOptions(
    dbName: 'DiaryApp',
    publicKey: 'DiaryAppKey',
  );

  Future<void> saveToken(String token) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
      webOptions: kIsWeb ? _webOptions : WebOptions.defaultOptions,
    );
  }

  Future<String?> getToken() async {
    return await _storage.read(
      key: _tokenKey,
      webOptions: kIsWeb ? _webOptions : WebOptions.defaultOptions,
    );
  }

  Future<void> deleteToken() async {
    await _storage.delete(
      key: _tokenKey,
      webOptions: kIsWeb ? _webOptions : WebOptions.defaultOptions,
    );
  }
}