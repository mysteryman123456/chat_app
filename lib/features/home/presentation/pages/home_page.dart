import 'package:chat_app/core/services/socket/socket_service.dart';
import 'package:chat_app/core/services/storage/user_session_service.dart';
import 'package:chat_app/features/chat/presentation/pages/chat_page.dart';
import 'package:chat_app/features/conversation/presentation/state/conversation_state.dart';
import 'package:chat_app/features/conversation/presentation/view_model/conversation_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late String _myUserId;

  @override
  void initState() {
    super.initState();
    _myUserId = ref.read(userSessionServiceProvider).getCurrentUserId() ?? '';
    Future.microtask(
        () => ref.read(conversationViewModelProvider.notifier).fetchConversations());
  }

  @override
  Widget build(BuildContext context) {
    final conversationState = ref.watch(conversationViewModelProvider);
    final onlineUsers = ref.watch(onlineUsersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        color: Colors.white70, size: 20),
                  ),
                ],
              ),
            ),

            // ── Conversation List ──────────────────────────────────────────
            Expanded(
              child: conversationState.status == ConversationStatus.loading &&
                      conversationState.conversations.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : conversationState.conversations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  color: Colors.white.withOpacity(0.15),
                                  size: 90),
                              const SizedBox(height: 16),
                              Text(
                                'No conversations yet',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white.withOpacity(0.4)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Search for someone to start chatting',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.25)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: conversationState.conversations.length,
                          padding: const EdgeInsets.only(top: 4),
                          itemBuilder: (context, index) {
                            final conv = conversationState.conversations[index];

                            // Who is the other person?
                            final name = conv.displayName;
                            final avatarLetter = conv.initial;
                            final imageUrl = conv.otherUserProfileImage;
                            // Check online status using the other user's ID
                            final isOnline = conv.otherUserId != null &&
                                onlineUsers.contains(conv.otherUserId);

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChatScreen(conversation: conv),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    // ── Avatar with online dot ─────────
                                    Stack(
                                      children: [
                                        // Profile image or initial
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor:
                                              const Color(0xFF6C5CE7),
                                          backgroundImage: imageUrl != null &&
                                                  imageUrl.isNotEmpty
                                              ? NetworkImage(imageUrl)
                                              : null,
                                          child: imageUrl == null ||
                                                  imageUrl.isEmpty
                                              ? Text(
                                                  avatarLetter,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        // Online indicator dot
                                        if (isOnline)
                                          Positioned(
                                            right: 1,
                                            bottom: 1,
                                            child: Container(
                                              width: 13,
                                              height: 13,
                                              decoration: BoxDecoration(
                                                color: Colors.greenAccent,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFF0D0D1A),
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 14),

                                    // ── Text info ─────────────────────
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            isOnline ? 'Online' : 'Tap to chat',
                                            style: TextStyle(
                                              color: isOnline
                                                  ? Colors.greenAccent
                                                  : Colors.white
                                                      .withOpacity(0.4),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ── Arrow ─────────────────────────
                                    const Icon(Icons.chevron_right,
                                        color: Colors.white24),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
