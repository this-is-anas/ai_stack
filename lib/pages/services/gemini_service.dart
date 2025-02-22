import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'YOUR-API-KEY';
  static const String _promptTemplate = """
  [ROLE]
  You are a professional prompt engineering assistant. 
  
  [TASK]
  Generate a highly optimized AI system prompt based on the user's input.
  - For story/narrative requests: Include characters, plot points, and genre
  - For image generation: Specify style, composition, and medium
  - Technical specs: Keep under 500 characters
  
  [INPUT]
  {USER_INPUT}
  
  [OUTPUT FORMAT]
  <Type: Story|Image>
  <Prompt>
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

      return response.text;
    } catch (e) {
      print('Gemini API Error: $e');
      return null;
    }
  }
}
