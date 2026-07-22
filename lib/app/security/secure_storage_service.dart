import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thin product facade over After secure storage.
class SecureStorageService {
  SecureStorageService(this._storage);

  final AfterSecureStorage _storage;

  Future<void> write(String key, String value) => _storage.write(key, value);

  Future<String?> read(String key) => _storage.read(key);

  Future<void> delete(String key) => _storage.delete(key);

  Future<void> writeHealthSecret(String name, String value) =>
      write('superhealth.secret.$name', value);

  Future<String?> readHealthSecret(String name) =>
      read('superhealth.secret.$name');
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(ref.watch(afterSecureStorageProvider));
});