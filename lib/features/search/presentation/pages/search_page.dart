import 'package:chat_app/features/conversation/presentation/view_model/conversation_viewmodel.dart';
import 'package:chat_app/features/search/presentation/state/search_state.dart';
import 'package:chat_app/features/search/presentation/view_model/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(searchViewModelProvider.notifier).searchUsers(query);
  }

  void _startConversation(String userId) async {
    final success = await ref.read(conversationViewModelProvider.notifier).createConversation(userId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation created successfully')),
      );
    } else if (mounted) {
      final error = ref.read(conversationViewModelProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to create conversation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    final horizontalPad = isWide ? screenWidth * 0.1 : 16.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Search Users',
            style: TextStyle(
                color: Colors.white, fontSize: isWide ? 22 : 18)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    horizontalPad, 16, horizontalPad, 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by username...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              Expanded(
                child: searchState.status == SearchStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : searchState.users.isEmpty
                        ? const Center(
                            child: Text(
                              'No users found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: searchState.users.length,
                            itemBuilder: (context, index) {
                              final user = searchState.users[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPad - 16),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: isWide ? 26 : 22,
                                    backgroundColor: Colors.blueAccent,
                                    backgroundImage:
                                        user.profileImage != null
                                            ? NetworkImage(
                                                user.profileImage!)
                                            : null,
                                    child: user.profileImage == null
                                        ? Text(
                                            user.username[0].toUpperCase())
                                        : null,
                                  ),
                                  title: Text(
                                    user.username,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isWide ? 16 : 14),
                                  ),
                                  subtitle: Text(
                                    user.email,
                                    style: const TextStyle(
                                        color: Colors.grey),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.chat,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _startConversation(user.id),
                                  ),
                                ),
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

