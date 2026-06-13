import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/constants.dart';
import '../models/models.dart';

/// FloodMap — wrapper flutter_map reusable
/// Menampilkan: OSM tiles + marker pin laporan + radius kuning area terdampak
///
/// [reports]       : list laporan untuk ditampilkan sebagai marker
/// [height]        : tinggi widget peta
/// [showRadius]    : tampilkan circle radius kuning (default true)
/// [markerColor]   : warna pin marker (default biru masyarakat)
/// [onTap]         : callback saat peta di-tap (untuk map picker)
/// [initialCenter] : titik pusat peta awal
/// [initialZoom]   : zoom level awal
class FloodMap extends StatelessWidget {
  final List<ReportModel> reports;
  final double height;
  final bool showRadius;
  final Color markerColor;
  final void Function(TapPosition, LatLng)? onTap;
  final LatLng? initialCenter;
  final double initialZoom;
  final LatLng? singlePin; // untuk map picker (1 pin interaktif)

  const FloodMap({
    super.key,
    this.reports = const [],
    this.height = 200,
    this.showRadius = false,
    this.markerColor = const Color(0xFF1a4fd4),
    this.onTap,
    this.initialCenter,
    this.initialZoom = 13,
    this.singlePin,
  });

  @override
  Widget build(BuildContext context) {
    final center = initialCenter ??
        (reports.isNotEmpty
            ? LatLng(reports.first.lat, reports.first.lng)
            : const LatLng(
                AppConstants.defaultLat, AppConstants.defaultLng));

    return SizedBox(
      height: height,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: initialZoom,
          onTap: onTap,
        ),
        children: [
          // ── Base tile layer ─────────────────────────────
          TileLayer(
            urlTemplate: AppConstants.osmTileUrl,
            userAgentPackageName: 'com.example.sistem_banjir',
          ),

          // ── Radius circle kuning ────────────────────────
          if (showRadius && reports.isNotEmpty)
            CircleLayer(
              circles: reports
                  .map((r) => CircleMarker(
                        point: LatLng(r.lat, r.lng),
                        radius: 150,
                        color: Colors.yellow.withOpacity(0.28),
                        borderColor: Colors.yellow.withOpacity(0.65),
                        borderStrokeWidth: 2,
                        useRadiusInMeter: true,
                      ))
                  .toList(),
            ),

          // ── Marker dari list laporan ────────────────────
          if (reports.isNotEmpty)
            MarkerLayer(
              markers: reports
                  .map((r) => Marker(
                        point: LatLng(r.lat, r.lng),
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.location_pin,
                          color: markerColor,
                          size: 32,
                        ),
                      ))
                  .toList(),
            ),

          // ── Single pin (map picker) ─────────────────────
          if (singlePin != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: singlePin!,
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.location_pin,
                    color: markerColor,
                    size: 36,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
