import 'package:chat_app/core/api/api_endpoints.dart';
import 'package:chat_app/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService(userSessionService: ref.read(userSessionServiceProvider));
});

class SocketService {
  final UserSessionService _userSessionService;
  IO.Socket? socket;

  SocketService({required UserSessionService userSessionService})
      : _userSessionService = userSessionService;

  void connectAndJoin(String conversationId) async {
    final userId = _userSessionService.getCurrentUserId();
    
    // We assume backend base URL here (usually api is /api, socket is on root)
    final url = ApiEndpoints.baseUrl.replaceAll('/api', '');

    socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      print('Socket Connected');
      if (userId != null) {
        socket!.emit('join_online', {'userId': userId});
      }
      socket!.emit('join_conversation', {'conversationId': conversationId});
    });
  }

  void sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
    String type = 'TEXT',
  }) {
    if (socket != null && socket!.connected) {
      socket!.emit('send_message', {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'type': type,
        'content': content,
        'receiver_info': {
          'receiver_id': receiverId,
          'by': senderId,
        }
      });
    }
  }

  void onMessageReceived(Function(dynamic) callback) {
    if (socket != null) {
      socket!.on('receive_message', callback);
    }
  }

  void disconnect() {
    if (socket != null) {
      socket!.disconnect();
      socket!.dispose();
    }
  }
}
