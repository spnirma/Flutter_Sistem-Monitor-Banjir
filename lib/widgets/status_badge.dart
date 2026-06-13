import 'package:flutter/material.dart';
import '../core/theme.dart';

/// StatusBadge — badge warna otomatis berdasarkan string status laporan
/// Status yang didukung: pending, diproses, selesai, batal
/// Dipakai di: ReportCard, DetailLaporanScreen, LaporanSayaScreen
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final bg   = _bg(s);
    final text = _text(s);
    final label = _label(s);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
    );
  }

  Color _bg(String s) {
    switch (s) {
      case 'pending':   return AppColors.statusPendingBg;
      case 'diproses':  return AppColors.statusDisprosesBg;
      case 'selesai':   return AppColors.statusSelesaiBg;
      case 'batal':     return AppColors.statusBatalBg;
      default:          return Colors.grey.shade100;
    }
  }

  Color _text(String s) {
    switch (s) {
      case 'pending':   return AppColors.statusPendingText;
      case 'diproses':  return AppColors.statusDisprosesText;
      case 'selesai':   return AppColors.statusSelesaiText;
      case 'batal':     return AppColors.statusBatalText;
      default:          return Colors.grey;
    }
  }

  String _label(String s) {
    switch (s) {
      case 'pending':   return 'Pending';
      case 'diproses':  return 'Diproses';
      case 'selesai':   return 'Selesai';
      case 'batal':     return 'Batal';
      default:          return s[0].toUpperCase() + s.substring(1);
    }
  }
}
