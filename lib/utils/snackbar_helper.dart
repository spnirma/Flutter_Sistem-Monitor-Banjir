import 'package:flutter/material.dart';

/// showSuccessSnackbar — snackbar hijau untuk aksi berhasil
void showSuccessSnackbar(BuildContext context, String message) {
  _show(
    context,
    message: message,
    backgroundColor: const Color(0xFF1a7a4a),
    icon: Icons.check_circle_outline,
  );
}

/// showErrorSnackbar — snackbar merah untuk error
void showErrorSnackbar(BuildContext context, String message) {
  _show(
    context,
    message: message,
    backgroundColor: const Color(0xFFd43c3c),
    icon: Icons.error_outline,
  );
}

/// showInfoSnackbar — snackbar abu untuk informasi netral
void showInfoSnackbar(BuildContext context, String message) {
  _show(
    context,
    message: message,
    backgroundColor: const Color(0xFF555555),
    icon: Icons.info_outline,
  );
}

/// showLoadingDialog — dialog loading blocking (tutup dengan Navigator.pop)
void showLoadingDialog(BuildContext context, {String message = 'Memproses...'}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    ),
  );
}

// ── Internal helper ───────────────────────────────────────────
void _show(
  BuildContext context, {
  required String message,
  required Color backgroundColor,
  required IconData icon,
}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
}
