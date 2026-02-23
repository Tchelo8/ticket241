
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveUser(Map<String, dynamic> userJson) async {
    await _storage.write(key: 'token', value: userJson['token']);
    await _storage.write(key: 'user', value: jsonEncode(userJson));
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userString = await _storage.read(key: 'user');
    if (userString != null) {
      return jsonDecode(userString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');
  }
}
