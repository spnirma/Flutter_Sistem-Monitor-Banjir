import 'package:flutter/material.dart';
import '../utils/date_helper.dart';

/// ChatBubble — bubble pesan untuk ChatRoomScreen
/// [isMe]    : true = bubble kanan (warna primary), false = bubble kiri (putih)
/// [body]    : isi pesan teks
/// [sentAt]  : waktu kirim pesan
/// [color]   : warna bubble milik sendiri (biru/hijau sesuai role)
class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String body;
  final DateTime sentAt;
  final Color color;

  const ChatBubble({
    super.key,
    required this.isMe,
    required this.body,
    required this.sentAt,
    this.color = const Color(0xFF1a4fd4),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 6,
          left: isMe ? 56 : 0,
          right: isMe ? 0 : 56,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: isMe ? color : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 12),
          ),
          border: isMe ? null : Border.all(color: const Color(0xFFDDE3F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: TextStyle(
                fontSize: 13,
                color: isMe ? Colors.white : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              timeAgo(sentAt),
              style: TextStyle(
                fontSize: 9,
                color: isMe ? Colors.white60 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
