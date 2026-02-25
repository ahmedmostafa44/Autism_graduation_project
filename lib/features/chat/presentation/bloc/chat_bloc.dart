import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat_message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<ChatInitialized>(_onInitialized);
    on<ChatMessageSent>(_onMessageSent);
  }

  Future<void> _onInitialized(ChatInitialized event, Emitter<ChatState> emit) async {
    final welcome = ChatMessage(
      id: '0',
      text: "Hi there! 👋 I'm your friend Buddy. How are you feeling today?",
      sender: MessageSender.bot,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      hasAudio: true,
    );
    emit(ChatLoaded(messages: [welcome]));
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    final userMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      text: event.text,
      sender: MessageSender.user,
      time: DateTime.now(),
    );

    emit(current.copyWith(messages: [...current.messages, userMsg], isBotTyping: true));
    await Future.delayed(const Duration(milliseconds: 1500));

    final botMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_bot',
      text: _getBotResponse(event.text),
      sender: MessageSender.bot,
      time: DateTime.now(),
      hasAudio: true,
    );

    final updated = state as ChatLoaded;
    emit(updated.copyWith(messages: [...updated.messages, botMsg], isBotTyping: false));
  }

  String _getBotResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('happy') || lower.contains('good')) return "That's wonderful! 😊 I'm so glad you're feeling happy today!";
    if (lower.contains('sad') || lower.contains('upset')) return "I'm sorry to hear that 💙 Would you like to play a game together?";
    if (lower.contains('game')) return "Great idea! Let's play Emotion Match — it's so fun! 🎮";
    return "Thanks for sharing! 😊 How can I help you today?";
  }
}
