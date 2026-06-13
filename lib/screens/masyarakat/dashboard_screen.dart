import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/bottom_nav.dart';

class DashboardMasyarakatScreen extends ConsumerStatefulWidget {
  const DashboardMasyarakatScreen({super.key});

  @override
  ConsumerState<DashboardMasyarakatScreen> createState() =>
      _DashboardMasyarakatScreenState();
}

class _DashboardMasyarakatScreenState
    extends ConsumerState<DashboardMasyarakatScreen> {
  int _navIndex = 0;

  static const _primaryBlue = Color(0xFF1a4fd4);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reportProvider.notifier).fetchMyReports());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final reportState = ref.watch(reportProvider);
    final reports = reportState.reports;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard Masyarakat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Halo, ${user?.name ?? ''}',
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _primaryBlue,
        onRefresh: () => ref.read(reportProvider.notifier).fetchMyReports(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stat cards
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Total laporan',
                      value: reports.length.toString(),
                      icon: Icons.description_outlined,
                      color: _primaryBlue,
                      bgColor: const Color(0xFFDDE8FB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      label: 'Wilayah rawan',
                      value: '0',
                      icon: Icons.map_outlined,
                      color: const Color(0xFFc0392b),
                      bgColor: const Color(0xFFfde8e8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      label: 'Potensi banjir',
                      value: '0%',
                      icon: Icons.water_drop_outlined,
                      color: const Color(0xFF8a6200),
                      bgColor: const Color(0xFFfef3d8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Info banner
              if (reports.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDDE3F0)),
                  ),
                  child: const Text(
                    'Belum ada wilayah rawan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 10),

              // Peta persebaran
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDDE3F0)),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 10, 12, 6),
                      child: Text('Persebaran banjir',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: const LatLng(-7.4479, 112.7183),
                          initialZoom: 12,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.sistem_banjir',
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
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tombol buat laporan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/masyarakat/laporan/buat'),
                  icon: const Icon(Icons.add),
                  label: const Text('Buat laporan baru'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        role: 'masyarakat',
        onTap: (i) {
          setState(() => _navIndex = i);
          switch (i) {
            case 1: context.push('/masyarakat/pantau'); break;
            case 2: context.push('/masyarakat/laporan'); break;
            case 3: context.push('/chat'); break;
            case 4: context.push('/profile'); break;
          }
        },
      ),
    );
  }
}
