import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/report_provider.dart';
import '../../widgets/report_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/bottom_nav.dart';

class LaporanMasukScreen extends ConsumerStatefulWidget {
  const LaporanMasukScreen({super.key});

  @override
  ConsumerState<LaporanMasukScreen> createState() => _LaporanMasukScreenState();
}

class _LaporanMasukScreenState extends ConsumerState<LaporanMasukScreen> {
  static const _primaryGreen = Color(0xFF1a7a4a);
  int _navIndex = 1;
  String _filterStatus = 'semua';
  final _searchCtrl = TextEditingController();

  final _filters = ['semua', 'pending', 'diproses', 'selesai', 'batal'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reportProvider.notifier).fetchAllReports());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportProvider);
    final filtered = state.reports.where((r) {
      final matchStatus =
          _filterStatus == 'semua' || r.status == _filterStatus;
      final q = _searchCtrl.text.toLowerCase();
      final matchSearch = q.isEmpty ||
          r.judul.toLowerCase().contains(q) ||
          (r.pelapor?.toLowerCase().contains(q) ?? false) ||
          r.alamat.toLowerCase().contains(q);
      return matchStatus && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        title: const Text('Laporan masuk',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Search + filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari laporan...',
                    hintStyle:
                        const TextStyle(color: Color(0xFFAAABBB), fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: Color(0xFF8899CC)),
                    filled: true,
                    fillColor: const Color(0xFFF4F6FD),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFFD0D8EE))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFFD0D8EE))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: _primaryGreen)),
                  ),
                ),
                const SizedBox(height: 8),
                // Filter chips
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final f = _filters[i];
                      final selected = _filterStatus == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filterStatus = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? _chipColor(f)
                                : _chipBgColor(f),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: selected
                                    ? _chipColor(f)
                                    : _chipBorderColor(f)),
                          ),
                          child: Text(
                            f[0].toUpperCase() + f.substring(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : _chipTextColor(f),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // List
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _primaryGreen))
                : filtered.isEmpty
                    ? const Center(
                        child: Text('Tidak ada laporan',
                            style: TextStyle(color: Colors.grey)))
                    : RefreshIndicator(
                        color: _primaryGreen,
                        onRefresh: () =>
                            ref.read(reportProvider.notifier).fetchAllReports(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final r = filtered[i];
                            return ReportCard(
                              report: r,
                              trailing: StatusBadge(status: r.status),
                              showEmail: true,
                              onTap: () =>
                                  context.push('/pemerintah/laporan/${r.id}'),
                              onDelete: () => _confirmDelete(r.id),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        role: 'pemerintah',
        onTap: (i) {
          setState(() => _navIndex = i);
          switch (i) {
            case 0: context.go('/pemerintah/dashboard'); break;
            case 2: context.push('/pemerintah/pantau'); break;
            case 3: context.push('/chat'); break;
            case 4: context.push('/profile'); break;
          }
        },
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus laporan?'),
        content:
            const Text('Laporan ini akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(reportProvider.notifier).deleteReport(id);
            },
            child:
                const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _chipColor(String f) {
    switch (f) {
      case 'pending': return const Color(0xFFd4a017);
      case 'diproses': return const Color(0xFF1a4fd4);
      case 'selesai': return _primaryGreen;
      case 'batal': return const Color(0xFFd43c3c);
      default: return _primaryGreen;
    }
  }

  Color _chipBgColor(String f) {
    switch (f) {
      case 'pending': return const Color(0xFFfdf3d8);
      case 'diproses': return const Color(0xFFdde8fb);
      case 'selesai': return const Color(0xFFe8f5ee);
      case 'batal': return const Color(0xFFfde8e8);
      default: return const Color(0xFFf0f0f0);
    }
  }

  Color _chipBorderColor(String f) => _chipBgColor(f);
  Color _chipTextColor(String f) {
    switch (f) {
      case 'pending': return const Color(0xFF8a6200);
      case 'diproses': return const Color(0xFF1a4fd4);
      case 'selesai': return _primaryGreen;
      case 'batal': return const Color(0xFF8a1f1f);
      default: return Colors.grey;
    }
  }
}
