import 'package:flutter/material.dart';
import '../../services/voice_recorder_service.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final bool isRecording;
  final VoiceRecorderService voiceRecorder;
  final VoidCallback onAttachTap;
  final VoidCallback onSendTap;
  final VoidCallback onCancelRecording;
  final VoidCallback onMicLongPressStart;
  final VoidCallback onMicLongPressEnd;
  final VoidCallback onMicLongPressCancel;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isSending,
    required this.isRecording,
    required this.voiceRecorder,
    required this.onAttachTap,
    required this.onSendTap,
    required this.onCancelRecording,
    required this.onMicLongPressStart,
    required this.onMicLongPressEnd,
    required this.onMicLongPressCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: isRecording ? _buildRecordingBar() : _buildNormalInputBar(context),
        ),
      ),
    );
  }

  Widget _buildNormalInputBar(BuildContext context) {
    return Row(
      children: [
        _buildCircleButton(
          icon: Icons.add_rounded,
          onTap: onAttachTap,
          color: Colors.grey.shade600,
          bgColor: Colors.grey.shade100,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSendTap(),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2D3142),
              ),
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onLongPressStart: (_) => onMicLongPressStart(),
          onLongPressEnd: (_) => onMicLongPressEnd(),
          onLongPressCancel: onMicLongPressCancel,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic_rounded,
              color: Colors.grey.shade600,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: isSending ? null : onSendTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isSending
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingBar() {
    return ValueListenableBuilder<Duration>(
      valueListenable: voiceRecorder.recordingDuration,
      builder: (_, duration, __) {
        final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
        final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

        return Row(
          children: [
            GestureDetector(
              onTap: onCancelRecording,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.grey.shade600,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$minutes:$seconds',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3142),
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Release to send',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color bgColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
