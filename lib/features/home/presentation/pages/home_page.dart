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
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(conversationViewModelProvider.notifier).fetchConversations());
  }

  @override
  Widget build(BuildContext context) {
    final conversationState = ref.watch(conversationViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black, // dark theme
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Messages",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: conversationState.status == ConversationStatus.loading &&
                        conversationState.conversations.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : conversationState.conversations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.white30,
                                  size: 100,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "No conversations yet",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white70),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: conversationState.conversations.length,
                            itemBuilder: (context, index) {
                              final conversation =
                                  conversationState.conversations[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: Text(
                                    conversation.type == "GROUP"
                                        ? "G"
                                        : "U", 
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  conversation.groupName ?? 'Direct Message',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: const Text(
                                  'Tap to view messages',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                          conversation: conversation),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
