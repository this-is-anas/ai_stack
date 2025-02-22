import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'YOUR-API-KEY';
  static const String _promptTemplate = """
You are a professional prompt engineering assistant. Generate a highly optimized AI system prompt based on these guidelines:

1. First line must specify type: "Type: Story" or "Type: Image"
2. Second line must start with "Prompt: "
3. No special characters or markdown
4. Keep under 500 characters

User Input: {USER_INPUT}
""";

  Future<String?> generateTailoredPrompt(String userInput) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topP: 0.9,
          maxOutputTokens: 500,
        ),
      );

      final fullPrompt = _promptTemplate.replaceAll('{USER_INPUT}', userInput);

      final response = await model.generateContent([
        Content.text(fullPrompt),
      ]);

      return response.text?.replaceAll(RegExp(r'[<>]'), '').trim();
    } catch (e) {
      print('Gemini API Error: $e');
      return null;
    }
  }
}
