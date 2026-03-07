import 'package:chat_app/core/api/api_endpoints.dart';
import 'package:chat_app/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class OnlineUsersNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void setOnlineUsers(List<String> userIds) {
    state = userIds.toSet();
  }
}

final onlineUsersProvider =
    NotifierProvider<OnlineUsersNotifier, Set<String>>(
        OnlineUsersNotifier.new);


final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService(
    userSessionService: ref.read(userSessionServiceProvider),
    ref: ref,
  );
});

class SocketService {
  final UserSessionService _userSessionService;
  final Ref _ref;
  IO.Socket? socket;

  SocketService({
    required UserSessionService userSessionService,
    required Ref ref,
  })  : _userSessionService = userSessionService,
        _ref = ref;

  void connectAndJoin(String conversationId) async {
    final userId = _userSessionService.getCurrentUserId();
    final url = ApiEndpoints.baseUrl.replaceAll('/api', '');

    socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      if (userId != null) {
        socket!.emit('join_online', {'userId': userId});
      }
      socket!.emit('join_conversation', {'conversationId': conversationId});
    });

    // Track who is online — backend emits 'online_users' with list of userIds
    socket!.on('online_users', (data) {
      if (data is List) {
        final ids = data.map((e) => e.toString()).toList();
        _ref.read(onlineUsersProvider.notifier).setOnlineUsers(ids);
      }
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

  // --- WebRTC Signaling Methods ---

  void callUser({
    required String conversationId,
    required String callerId,
    required String callerName,
  }) {
    if (socket != null && socket!.connected) {
      socket!.emit('call_user', {
        'conversationId': conversationId,
        'callerId': callerId,
        'callerName': callerName,
      });
    }
  }

  void onIncomingCall(Function(dynamic) callback) {
    if (socket != null) {
      socket!.on('incoming_call', callback);
    }
  }

  void acceptCall(String conversationId) {
    if (socket != null && socket!.connected) {
      socket!.emit('call_accepted', {'conversationId': conversationId});
    }
  }

  void onCallAccepted(Function(dynamic) callback) {
    if (socket != null) {
      socket!.on('call_accepted', callback);
    }
  }

  void rejectCall(String conversationId) {
    if (socket != null && socket!.connected) {
      socket!.emit('call_rejected', {'conversationId': conversationId});
    }
  }

  void onCallRejected(Function(dynamic) callback) {
    if (socket != null) {
      socket!.on('call_rejected', callback);
    }
  }

  void endCall(String conversationId) {
    if (socket != null && socket!.connected) {
      socket!.emit('call_ended', {'conversationId': conversationId});
    }
  }

  void onCallEnded(Function(dynamic) callback) {
    if (socket != null) {
      socket!.on('call_ended', callback);
    }
  }

  void sendOffer(String conversationId, Map<String, dynamic> offer) {
    if (socket != null && socket!.connected) {
      socket!.emit('offer', {
        'conversationId': conversationId,
        'offer': offer,
      });
    }
  }

  void onOffer(Function(dynamic) callback) {
    if (socket != null) {
      socket!.on('offer', callback);
    }
  }

  void sendAnswer(String conversationId, Map<String, dynamic> answer) {
    if (socket != null && socket!.connected) {
      socket!.emit('answer', {
        'conversationId': conversationId,
        'answer': answer,
      });
    }
  }

  void onAnswer(Function(dynamic) callback) {
    if (socket != null) {
      socket!.on('answer', callback);
    }
  }

  void sendIceCandidate(String conversationId, Map<String, dynamic> candidate) {
    if (socket != null && socket!.connected) {
      socket!.emit('ice-candidate', {
        'conversationId': conversationId,
        'candidate': candidate,
      });
    }
  }

  void onIceCandidate(Function(dynamic) callback) {
    if (socket != null) {
      socket!.on('ice-candidate', callback);
    }
  }
  
  void removeWebRtcListeners() {
    if (socket != null) {
      socket!.off('incoming_call');
      socket!.off('call_accepted');
      socket!.off('call_rejected');
      socket!.off('call_ended');
      socket!.off('offer');
      socket!.off('answer');
      socket!.off('ice-candidate');
    }
  }

  // -------------------------------


  void leaveAndDisconnect(String conversationId) {
    if (socket != null) {
      socket!.emit('leave_conversation', {'conversationId': conversationId});
      socket!.disconnect();
      socket!.dispose();
      socket = null;
    }
  }

  void disconnect() {
    if (socket != null) {
      socket!.disconnect();
      socket!.dispose();
      socket = null;
    }
  }
}
