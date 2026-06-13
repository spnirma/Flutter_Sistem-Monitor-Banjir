import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/date_helper.dart';

// ─────────────────────────────────────────────────
// 1. ConversationListScreen
// ─────────────────────────────────────────────────
class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(chatProvider.notifier).fetchConversations());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final isGreen = user?.isPemerintah ?? false;
    final primaryColor =
        isGreen ? const Color(0xFF1a7a4a) : const Color(0xFF1a4fd4);

    final state = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Pesan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : state.conversations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 52, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('Belum ada percakapan',
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.conversations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final conv = state.conversations[i];
                    return GestureDetector(
                      onTap: () => context.push('/chat/${conv.id}'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDDE3F0)),
                        ),
                        child: Row(
                          children: [
                            // Avatar inisial
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(conv.initials,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(conv.otherUser?.name ?? 'Unknown',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  if (conv.lastMessage != null)
                                    Text(conv.lastMessage!.body,
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(timeAgo(conv.updatedAt),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                                if (conv.hasUnread)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: Text(
                                          conv.unreadCount.toString(),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ─────────────────────────────────────────────────
// 2. ChatRoomScreen
// ─────────────────────────────────────────────────
class ChatRoomScreen extends ConsumerStatefulWidget {
  final int conversationId;
  const ChatRoomScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(chatProvider.notifier)
        .fetchMessages(widget.conversationId));
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send() async {
    final body = _msgCtrl.text.trim();
    if (body.isEmpty) return;
    _msgCtrl.clear();
    await ref
        .read(chatProvider.notifier)
        .sendMessage(widget.conversationId, body);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final isGreen = user?.isPemerintah ?? false;
    final primaryColor =
        isGreen ? const Color(0xFF1a7a4a) : const Color(0xFF1a4fd4);

    final state = ref.watch(chatProvider);
    final messages = state.messages[widget.conversationId] ?? [];
    final conv = state.conversations.cast().firstWhere(
          (c) => c.id == widget.conversationId,
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  conv?.initials ?? '?',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(conv?.otherUser.name ?? 'Chat',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chatbot banner
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.smart_toy_outlined,
                        color: Colors.white, size: 16),
                    SizedBox(width: 5),
                    Text('Tanya chatbot banjir',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Tanyakan seputar banjir, evakuasi, atau informasi darurat.',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'Contoh: Apa yang harus dilakukan saat banjir?',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.send,
                          color: Colors.white, size: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Info lawan bicara
          if (conv != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDDE3F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(conv.initials,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(conv.otherUser?.name ?? 'Unknown',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      Text(conv.otherUser.role,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // Messages
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('Belum ada pesan',
                        style: TextStyle(color: Colors.grey, fontSize: 12)))
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      final isMe = msg.isMe(user?.id ?? 0);
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: isMe ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(10),
                              topRight: const Radius.circular(10),
                              bottomLeft: Radius.circular(isMe ? 10 : 2),
                              bottomRight: Radius.circular(isMe ? 2 : 10),
                            ),
                            border: isMe
                                ? null
                                : Border.all(
                                    color: const Color(0xFFDDE3F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(msg.body,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: isMe
                                          ? Colors.white
                                          : Colors.black87)),
                              const SizedBox(height: 2),
                              Text(timeAgo(msg.createdAt),
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: isMe
                                          ? Colors.white60
                                          : Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Input bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_outlined,
                        size: 22, color: Colors.grey),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        hintStyle: const TextStyle(
                            color: Color(0xFFAAABBB), fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF4F6FD),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                const BorderSide(color: Color(0xFFDDE3F0))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                const BorderSide(color: Color(0xFFDDE3F0))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                BorderSide(color: primaryColor)),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.send,
                          color: Colors.white, size: 17),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
