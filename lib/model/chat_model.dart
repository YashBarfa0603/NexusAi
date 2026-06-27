class ChatModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;
  final MessageStatus status;
  final MessageType type;
  final String? filePath;
  final String? fileName;
  final String? mimeType;
  final double? progress;

  const ChatModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    this.filePath,
    this.fileName,
    this.mimeType,
    this.progress,
  });

  ChatModel copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? createdAt,
    MessageStatus? status,
    MessageType? type,
    String? filePath,
    String? fileName,
    String? mimeType,
    double? progress,
  }) {
    return ChatModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      progress: progress ?? this.progress,
    );
  }

  @override
String toString() {
  return 'ChatModel('
      'id: $id, '
      'text: $text, '
      'isUser: $isUser, '
      'status: $status, '
      'type: $type, '
      'fileName: $fileName, '
      'filePath: $filePath, '
      'mimeType: $mimeType, '
      'progress: $progress, '

      ')';
}
}

enum MessageStatus {
  sending,
  sent,
  error,
}

enum MessageType {
  text,
  document,
  voice,
  image,
}