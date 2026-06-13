import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../providers/report_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/bottom_nav.dart';
import '../../utils/date_helper.dart';

class PantauBanjirMasyarakatScreen extends ConsumerStatefulWidget {
  const PantauBanjirMasyarakatScreen({super.key});

  @override
  ConsumerState<PantauBanjirMasyarakatScreen> createState() =>
      _PantauBanjirMasyarakatScreenState();
}

class _PantauBanjirMasyarakatScreenState
    extends ConsumerState<PantauBanjirMasyarakatScreen> {
  static const _primaryBlue = Color(0xFF1a4fd4);
  int _navIndex = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reportProvider.notifier).fetchAllReports());
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportProvider).reports;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Pantau banjir',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Peta fullscreen bagian atas
          Expanded(
            flex: 5,
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(-7.4479, 112.7183),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.sistem_banjir',
                ),
                // Radius circle area terdampak (kuning)
                CircleLayer(
                  circles: reports
                      .map((r) => CircleMarker(
                            point: LatLng(r.lat, r.lng),
                            radius: 150,
                            color: Colors.yellow.withOpacity(0.3),
                            borderColor: Colors.yellow.withOpacity(0.7),
                            borderStrokeWidth: 2,
                            useRadiusInMeter: true,
                          ))
                      .toList(),
                ),
                MarkerLayer(
                  markers: reports
                      .map((r) => Marker(
                            point: LatLng(r.lat, r.lng),
                            width: 30,
                            height: 30,
                            child: const Icon(Icons.location_pin,
                                color: _primaryBlue, size: 30),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          // Legend
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellow.withOpacity(0.35),
                    border: Border.all(
                        color: Colors.yellow.withOpacity(0.7), width: 1.5),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Radius area terdampak banjir',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),

          // Daftar laporan di bawah peta
          Expanded(
            flex: 4,
            child: reports.isEmpty
                ? const Center(
                    child: Text('Belum ada laporan terpantau',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: reports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final r = reports[i];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDDE3F0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.judul,
                                      style: const TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 3),
                                  Row(children: [
                                    const Icon(Icons.person_outline,
                                        size: 12, color: Colors.grey),
                                    const SizedBox(width: 3),
                                    Text(r.pelapor ?? '-',
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                  ]),
                                  Row(children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 12, color: Colors.grey),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(r.alamat,
                                          style: const TextStyle(
                                              fontSize: 11, color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ]),
                                  Row(children: [
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 12, color: Colors.grey),
                                    const SizedBox(width: 3),
                                    Text(formatDate(r.createdAt),
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                  ]),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(status: r.status),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        role: 'masyarakat',
        onTap: (i) {
          setState(() => _navIndex = i);
          switch (i) {
            case 0: context.go('/masyarakat/dashboard'); break;
            case 2: context.push('/masyarakat/laporan'); break;
            case 3: context.push('/chat'); break;
            case 4: context.push('/profile'); break;
          }
        },
      ),
    );
  }
}
