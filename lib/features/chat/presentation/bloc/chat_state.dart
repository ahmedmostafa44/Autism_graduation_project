part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isBotTyping;

  ChatLoaded({required this.messages, this.isBotTyping = false});

  ChatLoaded copyWith({List<ChatMessage>? messages, bool? isBotTyping}) => ChatLoaded(
        messages: messages ?? this.messages,
        isBotTyping: isBotTyping ?? this.isBotTyping,
      );
}
