part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isBotTyping;
  final bool isLive; // true = real Gemini key is set

  ChatLoaded({
    required this.messages,
    this.isBotTyping = false,
    this.isLive = false,
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isBotTyping,
    bool? isLive,
  }) =>
      ChatLoaded(
        messages:    messages    ?? this.messages,
        isBotTyping: isBotTyping ?? this.isBotTyping,
        isLive:      isLive      ?? this.isLive,
      );
}
