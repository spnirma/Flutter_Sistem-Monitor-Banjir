import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/report_provider.dart';
import '../../widgets/report_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/bottom_nav.dart';

class LaporanSayaScreen extends ConsumerStatefulWidget {
  const LaporanSayaScreen({super.key});

  @override
  ConsumerState<LaporanSayaScreen> createState() => _LaporanSayaScreenState();
}

class _LaporanSayaScreenState extends ConsumerState<LaporanSayaScreen> {
  static const _primaryBlue = Color(0xFF1a4fd4);
  int _navIndex = 2;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reportProvider.notifier).fetchMyReports());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Laporan saya',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: RefreshIndicator(
        color: _primaryBlue,
        onRefresh: () => ref.read(reportProvider.notifier).fetchMyReports(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator(color: _primaryBlue))
            : state.reports.isEmpty
                ? _emptyState()
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      ...state.reports.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ReportCard(
                              report: r,
                              trailing: StatusBadge(status: r.status),
                              onTap: null, // masyarakat hanya lihat
                            ),
                          )),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
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
                    ],
                  ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        role: 'masyarakat',
        onTap: (i) {
          setState(() => _navIndex = i);
          switch (i) {
            case 0: context.go('/masyarakat/dashboard'); break;
            case 1: context.push('/masyarakat/pantau'); break;
            case 3: context.push('/chat'); break;
            case 4: context.push('/profile'); break;
          }
        },
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Belum ada laporan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            const Text('Ketuk tombol di bawah untuk membuat laporan banjir baru.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.push('/masyarakat/laporan/buat'),
              icon: const Icon(Icons.add),
              label: const Text('Buat laporan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
}
