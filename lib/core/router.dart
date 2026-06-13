import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/screens.dart';

// ─────────────────────────────────────────────────────────────
// routerProvider — bisa diakses dari main.dart dengan ref.watch
// ─────────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,     // rebuild router saat auth berubah
    redirect: (context, state) async {
      final user = ref.read(authProvider);
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Belum login → paksa ke /login
      if (!isLoggedIn && !isAuthRoute) return '/login';

      // Sudah login tapi masih di auth page → redirect ke dashboard
      if (isLoggedIn && isAuthRoute) {
        return user.isPemerintah
            ? '/pemerintah/dashboard'
            : '/masyarakat/dashboard';
      }

      // Masyarakat coba akses route pemerintah → tolak
      if (isLoggedIn && user.isMasyarakat &&
          state.matchedLocation.startsWith('/pemerintah')) {
        return '/masyarakat/dashboard';
      }

      // Pemerintah coba akses route masyarakat → tolak
      if (isLoggedIn && user.isPemerintah &&
          state.matchedLocation.startsWith('/masyarakat')) {
        return '/pemerintah/dashboard';
      }

      return null; // tidak ada redirect
    },
    routes: [
      // ── AUTH ──────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── MASYARAKAT ────────────────────────────────────────
      GoRoute(
        path: '/masyarakat/dashboard',
        name: 'masyarakat-dashboard',
        builder: (_, __) => const DashboardMasyarakatScreen(),
      ),
      GoRoute(
        path: '/masyarakat/laporan',
        name: 'laporan-saya',
        builder: (_, __) => const LaporanSayaScreen(),
      ),
      GoRoute(
        path: '/masyarakat/laporan/buat',
        name: 'form-laporan',
        builder: (_, __) => const FormLaporanScreen(),
      ),
      GoRoute(
        path: '/masyarakat/pantau',
        name: 'pantau-masyarakat',
        builder: (_, __) => const PantauBanjirMasyarakatScreen(),
      ),

      // ── PEMERINTAH ────────────────────────────────────────
      GoRoute(
        path: '/pemerintah/dashboard',
        name: 'pemerintah-dashboard',
        builder: (_, __) => const DashboardPemerintahScreen(),
      ),
      GoRoute(
        path: '/pemerintah/laporan',
        name: 'laporan-masuk',
        builder: (_, __) => const LaporanMasukScreen(),
      ),
      GoRoute(
        path: '/pemerintah/laporan/:id',
        name: 'detail-laporan',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DetailLaporanScreen(reportId: id);
        },
      ),
      GoRoute(
        path: '/pemerintah/pantau',
        name: 'pantau-pemerintah',
        builder: (_, __) => const PantauBanjirPemerintahScreen(),
      ),

      // ── SHARED ────────────────────────────────────────────
      GoRoute(
        path: '/chat',
        name: 'chat-list',
        builder: (_, __) => const ConversationListScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat-room',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ChatRoomScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const ProfileScreen(),
      ),
    ],

    // Halaman 404
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Halaman tidak ditemukan: ${state.matchedLocation}',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    ),
  );
});
