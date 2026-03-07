import 'dart:async';
import 'package:chat_app/core/services/socket/socket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

final webrtcServiceProvider = Provider<WebRtcService>((ref) {
  return WebRtcService(socketService: ref.read(socketServiceProvider));
});

class WebRtcService {
  final SocketService _socketService;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  String? _currentConversationId;
  bool _isCaller = false;

  // Callbacks for UI updates
  void Function(MediaStream)? onLocalStream;
  void Function(MediaStream)? onRemoteStream;
  void Function()? onCallEnded;
  void Function(RTCIceConnectionState)? onIceConnectionState;

  WebRtcService({required SocketService socketService})
      : _socketService = socketService {
    _initSignalingListeners();
  }

  void _initSignalingListeners() {
    _socketService.onCallAccepted((data) async {
      print("Call accepted by remote!");
      if (_isCaller) {
        await _createOffer();
      }
    });

    _socketService.onCallRejected((data) {
      print("Call rejected!");
      endCall();
    });

    _socketService.onCallEnded((data) {
      print("Call ended by remote!");
      _cleanUp();
      onCallEnded?.call();
    });

    _socketService.onOffer((data) async {
      print("Received offer!");
      if (_peerConnection == null) {
        await _createPeerConnection();
      }
      final offerMap = Map<String, dynamic>.from(data);
      final offer = RTCSessionDescription(offerMap['sdp'], offerMap['type']);
      await _peerConnection!.setRemoteDescription(offer);
      await _createAnswer();
    });

    _socketService.onAnswer((data) async {
      print("Received answer!");
      final answerMap = Map<String, dynamic>.from(data);
      final answer = RTCSessionDescription(answerMap['sdp'], answerMap['type']);
      await _peerConnection!.setRemoteDescription(answer);
    });

    _socketService.onIceCandidate((data) async {
      print("Received ICE Candidate!");
      final candidateMap = Map<String, dynamic>.from(data);
      final candidate = RTCIceCandidate(
        candidateMap['candidate'],
        candidateMap['sdpMid'],
        candidateMap['sdpMLineIndex'],
      );
      if (_peerConnection != null) {
        await _peerConnection!.addCandidate(candidate);
      }
    });
  }

  Future<void> initiateCall(String conversationId, String callerId, String callerName) async {
    _currentConversationId = conversationId;
    _isCaller = true;
    
    // We get user media first so the stream is ready when call starts
    await _getUserMedia();
    
    _socketService.callUser(
      conversationId: conversationId,
      callerId: callerId,
      callerName: callerName,
    );
  }

  Future<void> acceptIncomingCall(String conversationId) async {
    _currentConversationId = conversationId;
    _isCaller = false;
    
    await _getUserMedia();
    await _createPeerConnection();
    
    _socketService.acceptCall(conversationId);
  }

  void rejectIncomingCall(String conversationId) {
    _socketService.rejectCall(conversationId);
  }

  Future<void> _getUserMedia() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': false, 
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      onLocalStream?.call(_localStream!);
    } catch (e) {
      print("Error getting user media: $e");
    }
  }

  Future<void> _createPeerConnection() async {
    final configuration = <String, dynamic>{
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (_currentConversationId != null) {
         _socketService.sendIceCandidate(_currentConversationId!, {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      print("ICE Connection State: $state");
      onIceConnectionState?.call(state);
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      print("Received remote track!");
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        onRemoteStream?.call(_remoteStream!);
      }
    };

    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
    }
  }

  Future<void> _createOffer() async {
    if (_peerConnection == null) await _createPeerConnection();

    try {
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      if (_currentConversationId != null) {
         _socketService.sendOffer(_currentConversationId!, {
          'sdp': offer.sdp,
          'type': offer.type,
        });
      }
    } catch (e) {
      print("Error creating offer: $e");
    }
  }

  Future<void> _createAnswer() async {
    try {
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      if (_currentConversationId != null) {
        _socketService.sendAnswer(_currentConversationId!, {
          'sdp': answer.sdp,
          'type': answer.type,
        });
      }
    } catch (e) {
      print("Error creating answer: $e");
    }
  }

  void toggleMute(bool isMuted) {
    if (_localStream != null) {
      for (var track in _localStream!.getAudioTracks()) {
        track.enabled = !isMuted;
      }
    }
  }

  void toggleSpeaker(bool useSpeaker) {
     if (_remoteStream != null) {
        // flutter_webrtc manages audio output via helper.
        // For audio routing, Helper.setSpeakerphoneOn works primarily on Android/iOS native side.
        Helper.setSpeakerphoneOn(useSpeaker);
     }
  }

  void endCall() {
     if (_currentConversationId != null) {
       _socketService.endCall(_currentConversationId!);
     }
     _cleanUp();
     onCallEnded?.call();
  }

  void _cleanUp() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _localStream = null;

    _remoteStream?.dispose();
    _remoteStream = null;

    _peerConnection?.close();
    _peerConnection?.dispose();
    _peerConnection = null;

    _currentConversationId = null;
    _isCaller = false;
    
    // reset speaker phone 
    Helper.setSpeakerphoneOn(false);
  }
}
