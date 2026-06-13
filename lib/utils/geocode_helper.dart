import 'package:dio/dio.dart';
import '../core/constants.dart';

/// GeocodeHelper — konversi koordinat → alamat teks
/// Menggunakan Nominatim (OpenStreetMap) — gratis, tidak butuh API key
/// Dipakai di: FormLaporanScreen saat user tap peta
class GeocodeHelper {
  GeocodeHelper._();

  static final _dio = Dio(BaseOptions(
    baseUrl: AppConstants.nominatimUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      // Nominatim wajib ada User-Agent
      'User-Agent': 'SistemDrainasePintar/1.0',
    },
  ));

  /// Konversi lat/lng → string alamat
  /// Contoh hasil: "Taman Pinang Indah, Lemahputro, Sidoarjo, East Java, 61213, Indonesia"
  /// Jika gagal: kembalikan string koordinat sebagai fallback
  static Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final res = await _dio.get('', queryParameters: {
        'lat': lat,
        'lon': lng,
        'format': 'json',
        'addressdetails': 1,
      });

      final displayName = res.data['display_name'] as String?;
      if (displayName != null && displayName.isNotEmpty) {
        return displayName;
      }

      // Fallback: susun dari komponen address
      final addr = res.data['address'] as Map<String, dynamic>?;
      if (addr != null) {
        final parts = <String>[];
        for (final key in [
          'road', 'suburb', 'neighbourhood',
          'city', 'town', 'village',
          'county', 'state', 'postcode', 'country',
        ]) {
          final val = addr[key] as String?;
          if (val != null && val.isNotEmpty) parts.add(val);
        }
        if (parts.isNotEmpty) return parts.join(', ');
      }

      return _coordFallback(lat, lng);
    } catch (_) {
      return _coordFallback(lat, lng);
    }
  }

  static String _coordFallback(double lat, double lng) =>
      '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
}
