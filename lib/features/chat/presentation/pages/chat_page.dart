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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(conversationViewModelProvider.notifier).fetchMessages(widget.conversation.id);
      
      final socketService = ref.read(socketServiceProvider);
      socketService.connectAndJoin(widget.conversation.id);
      socketService.onMessageReceived((data) {
        if (mounted) {
          final message = MessageEntity(
            id: data['_id'] ?? const Uuid().v4(),
            conversationId: data['conversation_id'],
            senderId: data['sender_id'],
            type: data['type'] ?? 'TEXT',
            content: data['content'],
            createdAt: DateTime.now(),
          );
          ref.read(conversationViewModelProvider.notifier).addLocalMessage(message);
        }
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    ref.read(socketServiceProvider).disconnect();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    final myId = 'MY_USER_ID'; // Replace with real logic
    final receiverId = widget.conversation.participants.firstWhere(
      (id) => id != myId,
      orElse: () => '',
    );

    ref.read(socketServiceProvider).sendMessage(
      conversationId: widget.conversation.id,
      senderId: myId,
      receiverId: receiverId,
      content: text,
      type: 'TEXT',
    );
    
    // Optimistically add to UI
    final localMessage = MessageEntity(
      id: const Uuid().v4(),
      conversationId: widget.conversation.id,
      senderId: myId,
      type: 'TEXT',
      content: text,
      createdAt: DateTime.now(),
    );
    ref.read(conversationViewModelProvider.notifier).addLocalMessage(localMessage);

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final conversationState = ref.watch(conversationViewModelProvider);
    final messages = conversationState.messages;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          widget.conversation.groupName ?? 'Chat',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: conversationState.status == ConversationStatus.loading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      // Reverse index because list is reversed
                      final msg = messages[messages.length - 1 - index];
                      // Just a simple check for demo purposes, assume senderId mapping exists
                      final isMe = msg.senderId == 'MY_USER_ID'; 

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blueAccent : Colors.grey[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.content ?? '',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('hh:mm a').format(msg.createdAt),
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Colors.grey[900],
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
