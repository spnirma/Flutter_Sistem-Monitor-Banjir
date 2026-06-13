import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/models.dart';
import 'api_client.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final _dio = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  // ── Login ──────────────────────────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      AppConstants.epLogin,
      data: {'email': email, 'password': password},
    );
    final token = res.data['token'] as String;
    final user = UserModel.fromJson(
      res.data['user'] as Map<String, dynamic>,
      token: token,
    );
    await _saveUser(user);
    return user;
  }

  // ── Register ───────────────────────────────────────────────
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role, // 'masyarakat' | 'pemerintah'
  }) async {
    await _dio.post(
      AppConstants.epRegister,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
      },
    );
    // Tidak auto-login setelah register — user diarahkan ke login
  }

  // ── Logout ─────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _dio.post(AppConstants.epLogout);
    } catch (_) {
      // Tetap hapus storage meski request gagal
    } finally {
      await _clearStorage();
    }
  }

  // ── Auto-login: baca token dari storage ───────────────────
  Future<UserModel?> getStoredUser() async {
    final token = await _storage.read(key: AppConstants.keyToken);
    final idStr = await _storage.read(key: AppConstants.keyUserId);
    final name  = await _storage.read(key: AppConstants.keyUserName);
    final email = await _storage.read(key: AppConstants.keyUserEmail);
    final role  = await _storage.read(key: AppConstants.keyUserRole);

    if (token == null || idStr == null || name == null ||
        email == null || role == null) return null;

    return UserModel(
      id: int.parse(idStr),
      name: name,
      email: email,
      role: role,
      token: token,
    );
  }

  // ── Update profile ─────────────────────────────────────────
  Future<UserModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final res = await _dio.patch(
      AppConstants.epProfile,
      data: {'name': name, 'email': email},
    );
    final user = UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
    await _storage.write(key: AppConstants.keyUserName, value: user.name);
    await _storage.write(key: AppConstants.keyUserEmail, value: user.email);
    return user;
  }

  // ── Helpers ────────────────────────────────────────────────
  Future<void> _saveUser(UserModel user) async {
    await _storage.write(key: AppConstants.keyToken,    value: user.token);
    await _storage.write(key: AppConstants.keyUserId,   value: user.id.toString());
    await _storage.write(key: AppConstants.keyUserName, value: user.name);
    await _storage.write(key: AppConstants.keyUserEmail,value: user.email);
    await _storage.write(key: AppConstants.keyUserRole, value: user.role);
  }

  Future<void> _clearStorage() async {
    await _storage.deleteAll();
  }
}
