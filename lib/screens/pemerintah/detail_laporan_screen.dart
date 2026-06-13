import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/report_provider.dart';
import '../../widgets/status_badge.dart';
import '../../utils/date_helper.dart';
import '../../utils/snackbar_helper.dart';

class DetailLaporanScreen extends ConsumerStatefulWidget {
  final int reportId;
  const DetailLaporanScreen({super.key, required this.reportId});

  @override
  ConsumerState<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends ConsumerState<DetailLaporanScreen> {
  static const _primaryGreen = Color(0xFF1a7a4a);
  String? _selectedStatus;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportProvider).reports;
    final report = reports.cast<ReportModel?>().firstWhere(
          (r) => r?.id == widget.reportId,
          orElse: () => null,
        );

    if (report == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: _primaryGreen, foregroundColor: Colors.white),
        body: const Center(child: Text('Laporan tidak ditemukan')),
      );
    }

    _selectedStatus ??= report.status;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        title: const Text('Detail laporan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ── INFO CARD ──────────────────────────────────────
            _card(children: [
              _field(Icons.person_outline, 'Pelapor', report.pelapor ?? '-'),
              _divider(),
              _field(Icons.email_outlined, 'Email', report.emailPelapor ?? '-'),
              _divider(),
              _field(Icons.title, 'Judul laporan', report.judul),
              _divider(),
              _field(Icons.notes, 'Deskripsi',
                  report.deskripsi?.isEmpty ?? true ? '-' : report.deskripsi!),
              _divider(),
              _field(Icons.location_on_outlined, 'Alamat', report.alamat),
              _divider(),
              if (report.kategori != null) ...[
                _field(Icons.category_outlined, 'Kategori', report.kategori!),
                _divider(),
              ],
              if (report.tinggiAir != null) ...[
                _field(Icons.straighten, 'Estimasi tinggi air',
                    '${report.tinggiAir} cm'),
                _divider(),
              ],
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 15, color: Color(0xFF1a7a4a)),
                  const SizedBox(width: 6),
                  const Text('Status saat ini',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1a7a4a))),
                  const Spacer(),
                  StatusBadge(status: report.status),
                ],
              ),
              const SizedBox(height: 8),
              _field(Icons.calendar_today_outlined, 'Tanggal laporan',
                  formatDate(report.createdAt)),
            ]),
            const SizedBox(height: 10),

            // ── FOTO ───────────────────────────────────────────
            _card(children: [
              _sectionTitle(Icons.photo_outlined, 'Foto kejadian'),
              const SizedBox(height: 8),
              report.hasFoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        report.fotoUrl!,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _BrokenImage(),
                      ),
                    )
                  : const Text('Tidak ada foto yang diunggah',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic)),
            ]),
            const SizedBox(height: 10),

            // ── PETA ───────────────────────────────────────────
            _card(children: [
              _sectionTitle(Icons.map_outlined, 'Lokasi laporan'),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 160,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(report.lat, report.lng),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.sistem_banjir',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(report.lat, report.lng),
                            width: 36,
                            height: 36,
                            child: const Icon(Icons.location_pin,
                                color: _primaryGreen, size: 36),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 10),

            // ── UPDATE STATUS ──────────────────────────────────
            _card(children: [
              _sectionTitle(Icons.edit_outlined, 'Update status'),
              const SizedBox(height: 10),
              const Text('Pilih status:',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFFAFBFF),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD0D8EE))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD0D8EE))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _primaryGreen)),
                ),
                items: kStatusOptions
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s[0].toUpperCase() + s.substring(1),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedStatus = v),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _saveStatus,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Menyimpan...' : 'Simpan perubahan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('← Kembali ke daftar laporan',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ),
            ]),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _saveStatus() async {
    if (_selectedStatus == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(reportProvider.notifier)
          .updateStatus(widget.reportId, _selectedStatus!);
      if (!mounted) return;
      showSuccessSnackbar(context, 'Status berhasil diperbarui');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _card({required List<Widget> children}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDE3F0)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _sectionTitle(IconData icon, String title) => Row(children: [
        Icon(icon, size: 14, color: _primaryGreen),
        const SizedBox(width: 5),
        Text(title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primaryGreen)),
      ]);

  Widget _field(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 14, color: _primaryGreen),
          const SizedBox(width: 6),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _primaryGreen)),
              const SizedBox(height: 1),
              Text(value,
                  style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ]),
          ),
        ]),
      );

  Widget _divider() =>
      const Divider(height: 16, thickness: 0.5, color: Color(0xFFF0F0F0));
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();
  @override
  Widget build(BuildContext context) => Container(
        height: 100,
        color: const Color(0xFFF4F4F4),
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 36),
        ),
      );
}
