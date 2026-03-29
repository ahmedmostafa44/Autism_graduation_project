import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/services/gemini_service.dart';
import '../../data/models/chat_message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GeminiService _ai;
  final List<Map<String, String>> _history = [];

  ChatBloc({GeminiService? ai})
      : _ai = ai ?? GeminiService.instance,
        super(ChatInitial()) {
    on<ChatInitialized>(_onInit);
    on<ChatMessageSent>(_onMessage);
    on<ChatCleared>(_onCleared);
  }

void _onInit(ChatInitialized event, Emitter<ChatState> emit) {
  final welcome = ChatMessage(
    id: '0',
    text: "Hi there! 👋 I'm Buddy, your friend! How are you feeling today? 😊",
    sender: MessageSender.bot,
    time: DateTime.now(),
    hasAudio: true,
  );
  
  // DON'T add the welcome message to _history yet if it's the first thing.
  // Or, if you want it there, the API might require a dummy user message before it.
  // Best practice: Keep _history empty until the user actually speaks.
  
  emit(ChatLoaded(messages: [welcome], isLive: _ai.isConfigured));
}
  Future<void> _onMessage(
      ChatMessageSent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final text = event.text.trim();
    if (text.isEmpty) return;

    final userMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      sender: MessageSender.user,
      time: DateTime.now(),
    );

    emit(current.copyWith(
      messages: [...current.messages, userMsg],
      isBotTyping: true,
    ));

    // Inside ChatBloc _onMessage
    _history.add({'role': 'user', 'text': text});

  // Ensure history is alternating: user, model, user, model...
  final response = await _ai.sendMessage(
    userMessage: text,
    history: List.of(_history), 
  );

  _history.add({'role': 'model', 'text': response});
    if (_history.length > 20) _history.removeRange(0, _history.length - 20);

    final botMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_bot',
      text: response,
      sender: MessageSender.bot,
      time: DateTime.now(),
      hasAudio: true,
    );

    final updated = state as ChatLoaded;
    emit(updated.copyWith(
      messages: [...updated.messages, botMsg],
      isBotTyping: false,
    ));
  }

  void _onCleared(ChatCleared event, Emitter<ChatState> emit) {
    _history.clear();
    final welcome = ChatMessage(
      id: '0_new',
      text: "Hi again! 👋 I'm Buddy! How are you feeling right now? 😊",
      sender: MessageSender.bot,
      time: DateTime.now(),
      hasAudio: true,
    );
    _history.add({'role': 'model', 'text': welcome.text});
    emit(ChatLoaded(messages: [welcome], isLive: _ai.isConfigured));
  }
}
