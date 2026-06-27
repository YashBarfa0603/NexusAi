import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/chat_services.dart';
import '../services/file_picker_service.dart';
import '../services/voice_recorder_service.dart';
import '../model/chat_model.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final FilePickerService _filePickerService = FilePickerService();
  final VoiceRecorderService _voiceRecorder = VoiceRecorderService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<ChatModel> _messages = [];
  bool _isSending = false;
  bool _isRecording = false;
  String? _playingMessageId;
  String? _pendingFilePath;
  String? _pendingFileName;
  String? _pendingFileMime;
  MessageType? _pendingFileType;

  @override
  void initState() {
    super.initState();
    _voiceRecorder.isRecording.addListener(_onRecordingStateChanged);
  }

  void _onRecordingStateChanged() {
    if (mounted) {
      setState(() {
        _isRecording = _voiceRecorder.isRecording.value;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _voiceRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearPendingFile() {
    setState(() {
      _pendingFilePath = null;
      _pendingFileName = null;
      _pendingFileMime = null;
      _pendingFileType = null;
    });
  }

  

  Future<void> _pickImage() async {
    try {
      final result = await _filePickerService.pickImageFromGallery();
      if (result != null) {
        setState(() {
          _pendingFilePath = result.path;
          _pendingFileName = result.name;
          _pendingFileMime = result.mimeType;
          _pendingFileType = MessageType.image;
        });
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _takePhoto() async {
    try {
      final result = await _filePickerService.takePhoto();
      if (result != null) {
        setState(() {
          _pendingFilePath = result.path;
          _pendingFileName = result.name;
          _pendingFileMime = result.mimeType;
          _pendingFileType = MessageType.image;
        });
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await _filePickerService.pickDocument();
      if (result != null) {
        setState(() {
          _pendingFilePath = result.path;
          _pendingFileName = result.name;
          _pendingFileMime = result.mimeType;
          _pendingFileType = MessageType.document;
        });
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Share',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: const Color(0xFF6366F1),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage();
                  },
                ),
                _buildAttachOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: const Color(0xFFEC4899),
                  onTap: () {
                    Navigator.pop(ctx);
                    _takePhoto();
                  },
                ),
                _buildAttachOption(
                  icon: Icons.description_rounded,
                  label: 'Document',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickDocument();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  

  Future<void> _onMicLongPressStart() async {
    final started = await _voiceRecorder.startRecording();
    if (!started && mounted) {
      _showError('Could not start recording. Check microphone permission.');
    }
  }

  Future<void> _onMicLongPressEnd() async {
    if (!_isRecording) return;

    final path = await _voiceRecorder.stopRecording();
    if (path != null && mounted) {
      _sendVoiceMessage(path);
    }
  }

  Future<void> _onMicLongPressCancel() async {
    await _voiceRecorder.cancelRecording();
  }

  

  Future<void> _playAudio(String path, String messageId) async {
    if (_playingMessageId == messageId) {
      await _audioPlayer.stop();
      setState(() => _playingMessageId = null);
      return;
    }

    setState(() => _playingMessageId = messageId);
    await _audioPlayer.play(DeviceFileSource(path));
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingMessageId = null);
    });
  }

  

  Future<void> _sendMessage() async {
    if (_isSending) return;

    final message = _messageController.text.trim();

    if (_pendingFilePath != null) {
      _sendFileMessage(message);
      return;
    }

    if (message.isEmpty) return;

    final userMessage = ChatModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
      isUser: true,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isSending = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final reply = await _chatService.sendMessage(message);
      _addBotReply(reply);
    } catch (e) {
      _handleSendError(e);
    }
  }

  Future<void> _sendFileMessage(String message) async {
    final filePath = _pendingFilePath!;
    final fileName = _pendingFileName ?? 'file';
    final fileType = _pendingFileType ?? MessageType.image;

    final userMessage = ChatModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.isEmpty ? fileName : message,
      isUser: true,
      createdAt: DateTime.now(),
      type: fileType,
      filePath: filePath,
      fileName: fileName,
      mimeType: _pendingFileMime,
    );

    setState(() {
      _messages.add(userMessage);
      _isSending = true;
    });
    _messageController.clear();
    _clearPendingFile();
    _scrollToBottom();

    try {
      final typeStr = fileType == MessageType.image
          ? 'image'
          : fileType == MessageType.document
              ? 'document'
              : 'voice';

      final reply = await _chatService.sendMessageWithFile(
        message: message,
        filePath: filePath,
        fileType: typeStr,
      );
      _addBotReply(reply);
    } catch (e) {
      _handleSendError(e);
    }
  }

  Future<void> _sendVoiceMessage(String voicePath) async {
    final userMessage = ChatModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: 'Voice message',
      isUser: true,
      createdAt: DateTime.now(),
      type: MessageType.voice,
      filePath: voicePath,
      fileName: 'voice_note.m4a',
      mimeType: 'audio/mp4',
    );

    setState(() {
      _messages.add(userMessage);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final reply = await _chatService.sendMessageWithFile(
        message: '',
        filePath: voicePath,
        fileType: 'voice',
      );
      _addBotReply(reply);
    } catch (e) {
      _handleSendError(e);
    }
  }

  void _addBotReply(String reply) {
    final botMessage = ChatModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: reply,
      isUser: false,
      createdAt: DateTime.now(),
    );
    setState(() {
      _messages.add(botMessage);
      _isSending = false;
    });
    _scrollToBottom();
  }

  void _handleSendError(dynamic e) {
    debugPrint(e.toString());
    setState(() => _isSending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.replaceAll('Exception: ', '')),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_isSending) const BouncingTypingIndicator(),
          if (_pendingFilePath != null) _buildPendingFilePreview(),
          ChatInputBar(
            controller: _messageController,
            isSending: _isSending,
            isRecording: _isRecording,
            voiceRecorder: _voiceRecorder,
            onAttachTap: _showAttachmentSheet,
            onSendTap: _sendMessage,
            onCancelRecording: () => _voiceRecorder.cancelRecording(),
            onMicLongPressStart: _onMicLongPressStart,
            onMicLongPressEnd: _onMicLongPressEnd,
            onMicLongPressCancel: _onMicLongPressCancel,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      titleSpacing: 0,
      leadingWidth: 74,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Nexus AI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.3,
            ),
          ),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Online',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() => _messages.clear());
          },
          icon: Icon(
            Icons.delete_outline_rounded,
            color: Colors.grey.shade400,
            size: 22,
          ),
          tooltip: 'Clear chat',
        ),
        const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.black.withValues(alpha: 0.04),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showTimestamp = index == 0 ||
            message.createdAt.difference(_messages[index - 1].createdAt).inMinutes > 5;

        return Column(
          children: [
            if (showTimestamp) _buildTimestamp(message.createdAt),
            MessageBubble(
              message: message,
              playingMessageId: _playingMessageId,
              onPlayAudio: _playAudio,
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Hey! How can I help?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Send a message, photo, document, or voice note.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimestamp(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        '$hour:$minute $period',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPendingFilePreview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          if (_pendingFileType == MessageType.image && _pendingFilePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_pendingFilePath!),
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Color(0xFF6366F1),
                size: 22,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pendingFileName ?? 'File',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _pendingFileType == MessageType.image ? 'Image' : 'Document',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _clearPendingFile,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}