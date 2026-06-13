// ─────────────────────────────────────────────────────────────
// constants.dart
// Ganti baseUrl sesuai environment:
//   - Emulator Android : http://10.0.2.2:8000/api
//   - HP fisik (ngrok) : https://xxxx.ngrok.io/api
//   - Production       : https://api.domainmu.com/api
// ─────────────────────────────────────────────────────────────

class AppConstants {
  AppConstants._();

  // ── API ────────────────────────────────────────────────────
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const int connectTimeout = 15000; // ms
  static const int receiveTimeout = 15000; // ms

  // ── Storage keys (flutter_secure_storage) ─────────────────
  static const String keyToken    = 'auth_token';
  static const String keyUserId   = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail= 'user_email';
  static const String keyUserRole = 'user_role';

  // ── Endpoints ──────────────────────────────────────────────
  static const String epLogin          = '/login';
  static const String epRegister       = '/register';
  static const String epLogout         = '/logout';
  static const String epProfile        = '/profile';

  static const String epReports        = '/reports';          // masyarakat
  static const String epAdminReports   = '/admin/reports';    // pemerintah

  static const String epWaterLevels    = '/water-levels';

  static const String epChat           = '/chat';             // list conversation
  // /chat/{userId}      → show conversation
  // /chat/{convId}      → POST send message

  // ── Map ────────────────────────────────────────────────────
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String nominatimUrl =
      'https://nominatim.openstreetmap.org/reverse';

  // ── Default koordinat (Sidoarjo) ───────────────────────────
  static const double defaultLat = -7.4479;
  static const double defaultLng = 112.7183;

  // ── Chat polling interval ──────────────────────────────────
  static const int chatPollingSeconds = 5;
}
