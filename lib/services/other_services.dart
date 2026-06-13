// ─────────────────────────────────────────────────────────────
// other_services.dart
// Disesuaikan dengan struktur conversations:
// masyarakat_id, pemerintah_id (bukan pivot/participants)
// Dan messages: message (text), image (path), is_read
// ─────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/models.dart';
import 'api_client.dart';

// ─────────────────────────────────────────────────────────────
// WaterLevelService
// API /water-levels mengembalikan data dari tabel reports
// ─────────────────────────────────────────────────────────────
final waterLevelServiceProvider =
    Provider<WaterLevelService>((ref) => WaterLevelService());

class WaterLevelService {
  final _dio = ApiClient().dio;

  // Response berupa list laporan dengan koordinat
  // Kita parse sebagai ReportModel karena strukturnya sama
  Future<List<ReportModel>> getWaterLevels() async {
    final res = await _dio.get(AppConstants.epWaterLevels);
    final data = res.data['data'] as List;
    return data.map((j) {
      // Response water-levels sedikit berbeda dari reports
      // tambahkan field yang mungkin tidak ada
      final map = Map<String, dynamic>.from(j as Map<String, dynamic>);
      map['user_id']     ??= 0;
      map['description'] ??= '';
      map['updated_at']  ??= map['created_at'];
      return ReportModel.fromJson(map);
    }).toList();
  }
}

// ─────────────────────────────────────────────────────────────
// ChatService
// Conversations: masyarakat_id & pemerintah_id
// Messages: message (kolom text), image (path), is_read
// ─────────────────────────────────────────────────────────────
final chatServiceProvider =
    Provider<ChatService>((ref) => ChatService());

class ChatService {
  final _dio = ApiClient().dio;

  // GET /api/chat — list conversation milik user
  Future<List<ConversationModel>> getConversations(
      int currentUserId) async {
    final res = await _dio.get(AppConstants.epChat);
    final data = res.data['data'] as List;
    return data
        .map((j) => ConversationModel.fromJson(
              j as Map<String, dynamic>,
              currentUserId: currentUserId,
            ))
        .toList();
  }

  // GET /api/chat/{userId} — buka/buat conversation dengan user
  Future<ConversationModel> getOrCreateConversation(
      int userId, int currentUserId) async {
    final res = await _dio.get('${AppConstants.epChat}/$userId');
    return ConversationModel.fromJson(
      res.data['data'] as Map<String, dynamic>,
      currentUserId: currentUserId,
    );
  }

  // GET /api/chat/{convId}/messages — list pesan
  Future<List<MessageModel>> getMessages(int conversationId) async {
    final res = await _dio
        .get('${AppConstants.epChat}/$conversationId/messages');
    final data = res.data['data'] as List;
    return data
        .map((j) =>
            MessageModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // POST /api/chat/{convId} — kirim pesan
  // API menerima: 'message' (text)
  Future<MessageModel> sendMessage(
      int conversationId, String message) async {
    final res = await _dio.post(
      '${AppConstants.epChat}/$conversationId',
      data: {'message': message}, // field 'message' sesuai kolom DB
    );
    return MessageModel.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }
}
