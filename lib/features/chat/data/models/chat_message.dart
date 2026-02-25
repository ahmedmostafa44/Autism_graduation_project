import 'package:equatable/equatable.dart';

enum MessageSender { user, bot }

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime time;
  final bool hasAudio;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.time,
    this.hasAudio = false,
  });

  @override
  List<Object?> get props => [id, text, sender, time];
}
