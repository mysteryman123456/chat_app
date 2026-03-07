import 'package:chat_app/core/services/storage/user_session_service.dart';
import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';
import 'package:chat_app/features/conversation/presentation/state/conversation_state.dart';
import 'package:chat_app/features/conversation/presentation/view_model/conversation_viewmodel.dart';
import 'package:chat_app/core/services/socket/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/features/conversation/domain/entities/message_entity.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ConversationEntity conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _myUserId;
  SocketService? _socketService; 

  @override
  void initState() {
    super.initState();
    // Get real user ID from session
    _myUserId = ref.read(userSessionServiceProvider).getCurrentUserId() ?? '';

    Future.microtask(() {
      ref
          .read(conversationViewModelProvider.notifier)
          .fetchMessages(widget.conversation.id);

      _socketService = ref.read(socketServiceProvider);
      _socketService!.connectAndJoin(widget.conversation.id);

      _socketService!.onMessageReceived((data) {
        if (!mounted) return;
        // The receive_message payload mirrors the send_message payload:
        // { conversation_id, sender_id, type, content, receiver_info }
        // It may not have _id or createdAt — we generate them locally
        final rawDate = data['created_at'] ?? data['createdAt'];
        final message = MessageEntity(
          id: data['_id'] ?? const Uuid().v4(),
          conversationId: (data['conversation_id'] ?? '').toString(),
          senderId: (data['sender_id'] ?? '').toString(),
          type: (data['type'] ?? 'TEXT').toString(),
          content: (data['content'] ?? '').toString(),
          createdAt: rawDate != null
              ? (DateTime.tryParse(rawDate.toString()) ?? DateTime.now())
              : DateTime.now(),
        );
        ref
            .read(conversationViewModelProvider.notifier)
            .addLocalMessage(message);
        _scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Use cached reference — cannot call ref.read() inside dispose()
    _socketService?.leaveAndDisconnect(widget.conversation.id);
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Find receiver: first participant that is not me
    final receiverId = widget.conversation.participants
        .firstWhere((id) => id != _myUserId, orElse: () => '');

    final localMessage = MessageEntity(
      id: const Uuid().v4(),
      conversationId: widget.conversation.id,
      senderId: _myUserId,
      type: 'TEXT',
      content: text,
      createdAt: DateTime.now(),
    );

    // Emit to socket first
    ref.read(socketServiceProvider).sendMessage(
          conversationId: widget.conversation.id,
          senderId: _myUserId,
          receiverId: receiverId,
          content: text,
          type: 'TEXT',
        );

    // Optimistically add to local state
    ref
        .read(conversationViewModelProvider.notifier)
        .addLocalMessage(localMessage);

    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final conversationState = ref.watch(conversationViewModelProvider);

    // Sort messages oldest → newest so the ListView (reverse:true) shows
    // newest at bottom naturally
    final messages = [...conversationState.messages]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Derive a display name for the AppBar
    final otherParticipant = widget.conversation.participants
        .firstWhere((id) => id != _myUserId, orElse: () => '');
    final title = widget.conversation.groupName ??  
        (otherParticipant.isNotEmpty ? otherParticipant : 'Chat');

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF6C5CE7),
              child: Text(
                title.isNotEmpty ? title[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Messages List ──────────────────────────────────────────────
          Expanded(
            child: conversationState.status == ConversationStatus.loading &&
                    messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet.\nSay hi! 👋',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderId == _myUserId;
                          return _buildMessageBubble(msg, isMe);
                        },
                      ),
          ),

          // ── Input Bar ─────────────────────────────────────────────────
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageEntity msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 60 : 8,
          right: isMe ? 8 : 60,
        ),
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)])
              : null,
          color: isMe ? null : const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.content ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(msg.createdAt.toLocal()),
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border:
            Border(top: BorderSide(color: Color(0xFF2D2D44), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: const Color(0xFF0D0D1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

