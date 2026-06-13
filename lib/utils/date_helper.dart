/// date_helper.dart
/// Fungsi pembantu untuk format tanggal dan waktu relatif
/// Dipakai di: ReportCard, ChatBubble, ConversationListScreen

/// Format: "03 Mei 2026"
String formatDate(DateTime dt) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month]} ${dt.year}';
}

/// Format: "03 Mei 2026, 14:30"
String formatDateTime(DateTime dt) {
  return '${formatDate(dt)}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

/// Format relatif: "baru saja", "5 menit lalu", "2 jam lalu", "kemarin", "03 Mei 2026"
String timeAgo(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inSeconds < 60)  return 'baru saja';
  if (diff.inMinutes < 60)  return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24)    return '${diff.inHours} jam lalu';
  if (diff.inDays == 1)     return 'kemarin';
  if (diff.inDays < 7)      return '${diff.inDays} hari lalu';
  return formatDate(dt);
}

/// Format singkat untuk preview conversation: "14:30" jika hari ini, "Sen" jika minggu ini
String chatTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inDays == 0) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
  if (diff.inDays < 7) return days[dt.weekday % 7];

  return formatDate(dt);
}
