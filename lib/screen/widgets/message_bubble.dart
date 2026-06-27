import 'dart:io';
import 'package:flutter/material.dart';
import '../../model/chat_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatModel message;
  final String? playingMessageId;
  final Function(String path, String id) onPlayAudio;

  const MessageBubble({
    super.key,
    required this.message,
    required this.playingMessageId,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: message.type == MessageType.image
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF6366F1) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? const Color(0xFF6366F1).withOpacity(0.2)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: isUser ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildBubbleContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubbleContent(BuildContext context) {
    switch (message.type) {
      case MessageType.image:
        return _buildImageContent(context);
      case MessageType.document:
        return _buildDocumentContent();
      case MessageType.voice:
        return _buildVoiceContent();
      case MessageType.text:
        return _buildTextContent();
    }
  }

  Widget _buildTextContent() {
    return Text(
      message.text,
      style: TextStyle(
        fontSize: 15,
        height: 1.45,
        color: message.isUser ? Colors.white : const Color(0xFF2D3142),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: message.filePath != null
              ? Image.file(
                  File(message.filePath!),
                  width: 240,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 240,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image_rounded,
                        color: Colors.grey),
                  ),
                )
              : const SizedBox(),
        ),
        if (message.text.isNotEmpty && message.text != message.fileName)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color:
                    message.isUser ? Colors.white : const Color(0xFF2D3142),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentContent() {
    final isUser = message.isUser;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isUser
                ? Colors.white.withOpacity(0.2)
                : const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.description_rounded,
            color: isUser ? Colors.white : const Color(0xFF6366F1),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.fileName ?? 'Document',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isUser ? Colors.white : const Color(0xFF2D3142),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                message.mimeType?.split('/').last.toUpperCase() ?? 'FILE',
                style: TextStyle(
                  fontSize: 11,
                  color: isUser
                      ? Colors.white.withOpacity(0.7)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceContent() {
    final isUser = message.isUser;
    final isPlaying = playingMessageId == message.id;

    return GestureDetector(
      onTap: () {
        if (message.filePath != null) {
          onPlayAudio(message.filePath!, message.id);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.white.withOpacity(0.2)
                  : const Color(0xFF6366F1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isUser ? Colors.white : const Color(0xFF6366F1),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          // Waveform bars
          Row(
            children: List.generate(16, (i) {
              final heights = [8.0, 14.0, 10.0, 18.0, 12.0, 20.0, 14.0, 22.0,
                16.0, 12.0, 18.0, 10.0, 14.0, 8.0, 16.0, 12.0];
              return Container(
                width: 3,
                height: heights[i],
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isUser
                      ? Colors.white.withOpacity(isPlaying ? 1.0 : 0.5)
                      : const Color(0xFF6366F1)
                          .withOpacity(isPlaying ? 1.0 : 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(width: 10),
          Text(
            'Voice',
            style: TextStyle(
              fontSize: 12,
              color: isUser
                  ? Colors.white.withOpacity(0.7)
                  : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
