// ─────────────────────────────────────────────────────────────
// conversation_model.dart
// Disesuaikan dengan struktur tabel conversations:
// id, masyarakat_id, pemerintah_id, timestamps
// TIDAK pakai pivot/participants — langsung 2 kolom FK
// ─────────────────────────────────────────────────────────────

import 'message_model.dart';
import 'user_model.dart';

class ConversationModel {
  final int id;
  final int masyarakatId;
  final int pemerintahId;
  final UserModel? otherUser;   // user lawan bicara
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  const ConversationModel({
    required this.id,
    required this.masyarakatId,
    required this.pemerintahId,
    this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  bool get hasUnread => unreadCount > 0;

  /// Inisial untuk avatar (maks 2 huruf)
  String get initials {
    if (otherUser == null || otherUser!.name.isEmpty) return '?';
    final parts = otherUser!.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final name = parts[0];
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  factory ConversationModel.fromJson(
    Map<String, dynamic> json, {
    required int currentUserId,
  }) {
    // other_user sudah disiapkan oleh API
    UserModel? otherUser;
    if (json['other_user'] != null) {
      otherUser = UserModel.fromJson(
          json['other_user'] as Map<String, dynamic>);
    }

    // last_message
    MessageModel? lastMessage;
    if (json['last_message'] != null) {
      lastMessage = MessageModel.fromJson(
          json['last_message'] as Map<String, dynamic>);
    }

    return ConversationModel(
      id:            json['id'] as int,
      masyarakatId:  json['masyarakat_id'] as int,
      pemerintahId:  json['pemerintah_id'] as int,
      otherUser:     otherUser,
      lastMessage:   lastMessage,
      unreadCount:   json['unread_count'] as int? ?? 0,
      updatedAt:     DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  String toString() =>
      'ConversationModel(id: $id, with: ${otherUser?.name})';
}
