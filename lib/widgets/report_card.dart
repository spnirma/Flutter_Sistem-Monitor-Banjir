import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/date_helper.dart';

/// ReportCard — card laporan reusable
/// Dipakai di: LaporanMasukScreen (pemerintah), LaporanSayaScreen (masyarakat)
///
/// Parameter:
/// - [trailing]  : widget di pojok kanan atas (biasanya StatusBadge)
/// - [showEmail] : tampilkan email pelapor (hanya di sisi pemerintah)
/// - [onTap]     : buka detail laporan
/// - [onDelete]  : hapus laporan (hanya pemerintah, null = tidak tampil)
class ReportCard extends StatelessWidget {
  final ReportModel report;
  final Widget? trailing;
  final bool showEmail;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ReportCard({
    super.key,
    required this.report,
    this.trailing,
    this.showEmail = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE3F0)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // ── Main content ──────────────────────────────────
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul + trailing (badge)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          report.judul,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 8),
                        trailing!,
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Pelapor
                  if (report.pelapor != null)
                    _row(Icons.person_outline, report.pelapor!),

                  // Email (opsional, pemerintah)
                  if (showEmail && report.emailPelapor != null)
                    _row(Icons.email_outlined, report.emailPelapor!),

                  // Alamat
                  _row(Icons.location_on_outlined, report.alamat,
                      maxLines: 2),

                  // Tanggal
                  _row(Icons.calendar_today_outlined, formatDate(report.createdAt)),

                  // Estimasi tinggi air (jika ada)
                  if (report.tinggiAir != null)
                    _row(Icons.straighten, '${report.tinggiAir} cm'),
                ],
              ),
            ),
          ),

          // ── Action bar (tampil jika ada onTap atau onDelete) ──
          if (onTap != null || onDelete != null)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF0F0F0)),
                ),
              ),
              child: Row(
                children: [
                  if (onTap != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility_outlined,
                            size: 15, color: Color(0xFF1a7a4a)),
                        label: const Text(
                          'Detail',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF1a7a4a)),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: const RoundedRectangleBorder(),
                        ),
                      ),
                    ),
                  if (onTap != null && onDelete != null)
                    const SizedBox(
                      height: 24,
                      child: VerticalDivider(
                          width: 1, color: Color(0xFFF0F0F0)),
                    ),
                  if (onDelete != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline,
                            size: 15, color: Color(0xFFd43c3c)),
                        label: const Text(
                          'Hapus',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFd43c3c)),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: const RoundedRectangleBorder(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text, {int maxLines = 1}) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 13, color: Colors.grey),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}
