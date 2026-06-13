// ─────────────────────────────────────────────────────────────
// message_model.dart
// Disesuaikan dengan kolom tabel messages:
// id, conversation_id, sender_id, message (text),
// image (path), is_read (boolean), timestamps
// API response menambahkan: body (alias message), image_url
// ─────────────────────────────────────────────────────────────

class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String? message;   // kolom asli di DB: 'message'
  final String? imageUrl;  // image_url (full URL dari Storage::url)
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.message,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
  });

  // Getter body — Flutter pakai 'body' sebagai alias
  String get body => message ?? '';
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasText  => message != null && message!.isNotEmpty;

  /// Cek apakah pesan ini milik user yang sedang login
  bool isMe(int currentUserId) => senderId == currentUserId;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id:             json['id'] as int,
      conversationId: json['conversation_id'] as int,
      senderId:       json['sender_id'] as int,
      // API mengirim 'body' dan 'message' — ambil salah satu
      message:        json['body'] as String?
                      ?? json['message'] as String?,
      imageUrl:       json['image_url'] as String?,
      isRead:         json['is_read'] as bool? ?? false,
      createdAt:      DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id':              id,
        'conversation_id': conversationId,
        'sender_id':       senderId,
        'message':         message,
        'is_read':         isRead,
        'created_at':      createdAt.toIso8601String(),
      };

  @override
  String toString() =>
      'MessageModel(id: $id, senderId: $senderId, message: $message)';
}
