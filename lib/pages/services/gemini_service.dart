import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyBLbFFZVsXlqrth6QK-mSWIMdpbhgeFEsQ';
  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: _apiKey,
        );

  Future<String> generatePrompt(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Could not generate prompt';
    } catch (e) {
      throw Exception('Prompt generation failed: $e');
    }
  }
}
