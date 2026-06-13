import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

// ─────────────────────────────────────────────────────────────
// authProvider — state: UserModel? (null = belum login)
// ─────────────────────────────────────────────────────────────
final authProvider = NotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<UserModel?> implements Listenable {
  final _listeners = <VoidCallback>[];
  late final AuthService _service;

  @override
  UserModel? build() {
    _service = ref.read(authServiceProvider);
    // Load stored user saat app pertama buka
    _loadStoredUser();
    return null; // awal null, diisi setelah _loadStoredUser selesai
  }

  // GoRouter refresh trigger
  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notify() {
    for (final l in _listeners) l();
  }

  // ── Auto-login dari storage ───────────────────────────────
  Future<void> _loadStoredUser() async {
    final user = await _service.getStoredUser();
    state = user;
    _notify();
  }

  // ── Login ─────────────────────────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final user = await _service.login(email: email, password: password);
    state = user;
    _notify();
    return user;
  }

  // ── Register ──────────────────────────────────────────────
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await _service.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    // Tidak set state — user diarahkan ke login
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    await _service.logout();
    state = null;
    _notify();
  }

  // ── Update nama/email lokal ───────────────────────────────
  void updateLocal({String? name, String? email}) {
    if (state == null) return;
    state = state!.copyWith(name: name, email: email);
    _notify();
  }
}
