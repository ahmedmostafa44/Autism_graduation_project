import 'package:flutter/foundation.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiService {
  GeminiService._();
  static final instance = GeminiService._();

  // 🔑 IMPORTANT: Replace with your actual key
  static const apiKey = 'AIzaSyDUDU3Kx-ktdEr6Dwap6Bh-qUj1X1mlX0Q';

  static const _systemPrompt =
      'You are Buddy, a warm AI friend for children with ASD. '
      'Use simple language (ages 4-12). Max 2-4 short sentences. '
      'Use 1-3 emojis. No idioms. Validate feelings first. '
      'Suggest: Emotion Match 😊, Word Builder 📝, Color Match 🎨.';

  static void init() {
    if (apiKey.isEmpty || apiKey.startsWith('gen-lang')) {
      debugPrint('⚠️ [Gemini] Invalid API key — using mocks');
      return;
    }
    // Updated initialization for 2026 standards
    Gemini.init(apiKey: apiKey, enableDebugging: kDebugMode);
    debugPrint('✅ [Gemini] Initialized with 1.5 Flash');
  }

  bool get isConfigured => apiKey.startsWith('AIza');

  Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, String>> history,
  }) async {
    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        // 🔗 LINKING: Map history to the required 'Content' objects
        final chatHistory = history.map((turn) {
          return Content(
            role: turn['role'] == 'model' ? 'model' : 'user',
            parts: [Part.text(turn['text'] ?? '')],
          );
        }).toList();

        // Use the updated 'chat' method signature
        final response = await Gemini.instance.chat(
          chatHistory,
          // Explicitly use the 2026 stable model ID
          modelName: 'models/gemini-1.5-flash', 
        );

        // Note: systemPrompt is often handled via the first history entry 
        // in some package versions, but if the param exists, keep it.
        return response?.output ?? _mockResponse(userMessage);

      } catch (e) {
        if (e.toString().contains('429')) {
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount * 2));
        } else {
          debugPrint('❌ [Gemini] Connection Error: $e');
          break;
        }
      }
    }
    return _mockResponse(userMessage);
  }

  String _mockResponse(String input) {
    return "I'm here for you! 💙 Want to play Color Match 🎨?";
  }
}