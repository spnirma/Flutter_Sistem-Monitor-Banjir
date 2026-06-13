import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/other_services.dart';

// ─────────────────────────────────────────────────────────────
// State class
// ─────────────────────────────────────────────────────────────
class ChatState {
  final List<ConversationModel> conversations;
  final Map<int, List<MessageModel>> messages; // conversationId → messages
  final bool isLoading;
  final bool isSending;
  final String? error;

  const ChatState({
    this.conversations = const [],
    this.messages = const {},
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    List<ConversationModel>? conversations,
    Map<int, List<MessageModel>>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) =>
      ChatState(
        conversations: conversations ?? this.conversations,
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        error: error,
      );
}

// ─────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────
final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

class ChatNotifier extends Notifier<ChatState> {
  late final ChatService _service;
  Timer? _pollingTimer;
  int? _activeConvId; // conversation yang sedang dibuka

  @override
  ChatState build() {
    _service = ref.read(chatServiceProvider);
    // Hentikan polling saat provider di-dispose
    ref.onDispose(() => _stopPolling());
    return const ChatState();
  }

  int get _currentUserId => ref.read(authProvider)?.id ?? 0;

  // ── Fetch list conversation ────────────────────────────────
  Future<void> fetchConversations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final convs = await _service.getConversations(_currentUserId);
      state = state.copyWith(conversations: convs, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ── Fetch pesan + mulai polling ───────────────────────────
  Future<void> fetchMessages(int conversationId) async {
    _activeConvId = conversationId;
    await _loadMessages(conversationId);
    _startPolling(conversationId);
  }

  Future<void> _loadMessages(int conversationId) async {
    try {
      final msgs = await _service.getMessages(conversationId);
      final updated = Map<int, List<MessageModel>>.from(state.messages);
      updated[conversationId] = msgs;
      state = state.copyWith(messages: updated);
    } catch (_) {}
  }

  // ── Kirim pesan ───────────────────────────────────────────
  Future<void> sendMessage(int conversationId, String body) async {
    state = state.copyWith(isSending: true);
    try {
      final msg = await _service.sendMessage(conversationId, body);
      final updated = Map<int, List<MessageModel>>.from(state.messages);
      updated[conversationId] = [...(updated[conversationId] ?? []), msg];
      state = state.copyWith(messages: updated, isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ── Polling setiap N detik ────────────────────────────────
  void _startPolling(int conversationId) {
    _stopPolling();
    _pollingTimer = Timer.periodic(
      Duration(seconds: AppConstants.chatPollingSeconds),
      (_) => _loadMessages(conversationId),
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _activeConvId = null;
  }

  // Panggil ini saat user keluar dari chat room
  void leaveRoom() => _stopPolling();
}
