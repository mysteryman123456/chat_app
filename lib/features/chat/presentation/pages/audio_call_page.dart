import 'package:chat_app/core/services/webrtc/webrtc_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioCallPage extends ConsumerStatefulWidget {
  final String conversationId;
  final String callerName;
  final bool isIncoming;

  const AudioCallPage({
    super.key,
    required this.conversationId,
    required this.callerName,
    this.isIncoming = false,
  });

  @override
  ConsumerState<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends ConsumerState<AudioCallPage> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  late final WebRtcService _webRtcService;

  @override
  void initState() {
    super.initState();
    _webRtcService = ref.read(webrtcServiceProvider);

    _webRtcService.onCallEnded = () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    };

    if (widget.isIncoming) {
      _webRtcService.acceptIncomingCall(widget.conversationId);
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _webRtcService.toggleMute(_isMuted);
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    _webRtcService.toggleSpeaker(_isSpeakerOn);
  }

  void _endCall() {
    _webRtcService.endCall();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // User Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF6C5CE7),
              child: Text(
                widget.callerName.isNotEmpty
                    ? widget.callerName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              widget.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "Audio Calling...",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A2E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: "Mute",
                    isActive: _isMuted,
                    onTap: _toggleMute,
                  ),
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: "End",
                    isActive: true,
                    isDestructive: true,
                    onTap: _endCall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final color = isDestructive
        ? Colors.redAccent
        : (isActive ? Colors.white : Colors.white.withOpacity(0.3));

    final bgColor = isDestructive
        ? Colors.redAccent.withOpacity(0.2)
        : (isActive ? Colors.white.withOpacity(0.2) : Colors.transparent);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(isDestructive ? 24 : 16),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: isDestructive
                  ? null
                  : Border.all(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
            ),
            child: Icon(
              icon,
              color: color,
              size: isDestructive ? 32 : 28,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
