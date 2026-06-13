import 'package:flutter/material.dart';

/// StatCard — kartu angka statistik reusable
/// Dipakai di: DashboardMasyarakat (3 card) & DashboardPemerintah (4 card)
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;     // warna icon & teks value
  final Color bgColor;   // warna background card

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
