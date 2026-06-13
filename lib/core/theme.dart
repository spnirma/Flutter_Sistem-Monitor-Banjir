import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// Warna utama per role
// ─────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Masyarakat — biru
  static const Color masyarakatPrimary   = Color(0xFF1a4fd4);
  static const Color masyarakatLight     = Color(0xFFDDE8FB);
  static const Color masyarakatDark      = Color(0xFF1238A8);

  // Pemerintah — hijau
  static const Color pemerintahPrimary   = Color(0xFF1a7a4a);
  static const Color pemerintahLight     = Color(0xFFE1F5EE);
  static const Color pemerintahDark      = Color(0xFF0F5233);

  // Status laporan
  static const Color statusPending       = Color(0xFFd4a017);
  static const Color statusPendingBg     = Color(0xFFfdf3d8);
  static const Color statusPendingText   = Color(0xFF8a6200);

  static const Color statusDisproses     = Color(0xFF1a4fd4);
  static const Color statusDisprosesBg   = Color(0xFFDDE8FB);
  static const Color statusDisprosesText = Color(0xFF1a4fd4);

  static const Color statusSelesai       = Color(0xFF1a7a4a);
  static const Color statusSelesaiBg     = Color(0xFFe8f5ee);
  static const Color statusSelesaiText   = Color(0xFF0f5e38);

  static const Color statusBatal         = Color(0xFFd43c3c);
  static const Color statusBatalBg       = Color(0xFFfde8e8);
  static const Color statusBatalText     = Color(0xFF8a1f1f);

  // Umum
  static const Color background          = Color(0xFFF2F4F8);
  static const Color cardBorder          = Color(0xFFDDE3F0);
  static const Color inputBorder         = Color(0xFFD0D8EE);
  static const Color hintText            = Color(0xFFAAABBB);
  static const Color inputFill           = Color(0xFFFAFBFF);
}

// ─────────────────────────────────────────────────────────────
// ThemeData masyarakat (biru)
// ─────────────────────────────────────────────────────────────
final ThemeData masyarakatTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.masyarakatPrimary,
    primary: AppColors.masyarakatPrimary,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.masyarakatPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.masyarakatPrimary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
  inputDecorationTheme: _inputTheme(AppColors.masyarakatPrimary),
  cardTheme: _cardTheme(),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: AppColors.masyarakatPrimary,
    unselectedItemColor: Colors.grey,
    backgroundColor: Colors.white,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
    unselectedLabelStyle: const TextStyle(fontSize: 10),
  ),
);

// ─────────────────────────────────────────────────────────────
// ThemeData pemerintah (hijau)
// ─────────────────────────────────────────────────────────────
final ThemeData pemerintahTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.pemerintahPrimary,
    primary: AppColors.pemerintahPrimary,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.pemerintahPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.pemerintahPrimary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
  inputDecorationTheme: _inputTheme(AppColors.pemerintahPrimary),
  cardTheme: _cardTheme(),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: AppColors.pemerintahPrimary,
    unselectedItemColor: Colors.grey,
    backgroundColor: Colors.white,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
    unselectedLabelStyle: const TextStyle(fontSize: 10),
  ),
);

// ─────────────────────────────────────────────────────────────
// Helper: shared input theme
// ─────────────────────────────────────────────────────────────
InputDecorationTheme _inputTheme(Color focusColor) => InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      hintStyle: const TextStyle(color: AppColors.hintText, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: focusColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );

CardThemeData _cardTheme() => CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
    );
