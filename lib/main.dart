import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/core.dart';
import 'providers/providers.dart';

void main() {
  runApp(
    const ProviderScope(child: SistemBanjirApp()),
  );
}

class SistemBanjirApp extends ConsumerWidget {
  const SistemBanjirApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final user   = ref.watch(authProvider);

    // Pilih tema berdasarkan role user yang login
    final theme = user?.isPemerintah == true
        ? pemerintahTheme   // hijau
        : masyarakatTheme;  // biru (default & masyarakat)

    return MaterialApp.router(
      title: 'Sistem Drainase Pintar',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
    );
  }
}
