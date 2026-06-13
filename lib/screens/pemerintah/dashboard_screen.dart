import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/bottom_nav.dart';

class DashboardPemerintahScreen extends ConsumerStatefulWidget {
  const DashboardPemerintahScreen({super.key});

  @override
  ConsumerState<DashboardPemerintahScreen> createState() =>
      _DashboardPemerintahScreenState();
}

class _DashboardPemerintahScreenState
    extends ConsumerState<DashboardPemerintahScreen> {
  static const _primaryGreen = Color(0xFF1a7a4a);
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reportProvider.notifier).fetchAllReports());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final reports = ref.watch(reportProvider).reports;

    final total = reports.length;
    final pending = reports.where((r) => r.isPending).length;
    final batal = reports.where((r) => r.isBatal).length;
    final selesai = reports.where((r) => r.isSelesai).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard Pemerintah',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(user?.name ?? '',
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifPanel(context),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _primaryGreen,
        onRefresh: () => ref.read(reportProvider.notifier).fetchAllReports(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stat cards 2x2
              Row(children: [
                Expanded(
                  child: StatCard(
                    label: 'Total laporan',
                    value: total.toString(),
                    icon: Icons.description_outlined,
                    color: const Color(0xFF2979d4),
                    bgColor: const Color(0xFFdde8fb),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    label: 'Pending',
                    value: pending.toString(),
                    icon: Icons.hourglass_empty,
                    color: const Color(0xFF8a6200),
                    bgColor: const Color(0xFFfdf3d8),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: StatCard(
                    label: 'Batal',
                    value: batal.toString(),
                    icon: Icons.cancel_outlined,
                    color: const Color(0xFFd43c3c),
                    bgColor: const Color(0xFFfde8e8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    label: 'Selesai',
                    value: selesai.toString(),
                    icon: Icons.check_circle_outline,
                    color: _primaryGreen,
                    bgColor: const Color(0xFFe8f5ee),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

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
                      child: Text('Persebaran laporan banjir',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: const MapOptions(
                          initialCenter: LatLng(-7.4479, 112.7183),
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
                                          color: _primaryGreen, size: 30),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Quick action cards
              Row(children: [
                Expanded(
                  child: _quickCard(
                    icon: Icons.inbox_outlined,
                    title: 'Laporan terbaru',
                    subtitle: 'Kelola laporan masuk',
                    onTap: () => context.push('/pemerintah/laporan'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _quickCard(
                    icon: Icons.bar_chart_outlined,
                    title: 'Statistik & analisis',
                    subtitle: 'Tren banjir wilayah',
                    onTap: () {},
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        role: 'pemerintah',
        onTap: (i) {
          setState(() => _navIndex = i);
          switch (i) {
            case 1: context.push('/pemerintah/laporan'); break;
            case 2: context.push('/pemerintah/pantau'); break;
            case 3: context.push('/chat'); break;
            case 4: context.push('/profile'); break;
          }
        },
      ),
    );
  }

  Widget _quickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDE3F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: _primaryGreen),
                  const SizedBox(height: 4),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                textStyle: const TextStyle(fontSize: 11),
              ),
              child: const Text('Lihat'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            const Text('Notifikasi terbaru',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            const Icon(Icons.notifications_off_outlined,
                size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            const Text('Tidak ada notifikasi',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
