import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey =
      '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'; // Your OpenRouter key
  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'deepssek-r1:free'; // Official R1 model ID

  Future<String?> generatePrompt(String userInput) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://your-domain.com', // Required header
          'X-Title': 'AI Hub', // Your app name
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a creative AI assistant that generates innovative project ideas.',
            },
            {
              'role': 'user',
              'content':
                  'Generate a detailed AI project concept about: $userInput',
            }
          ],
          'temperature': 0.6, // Optimal for R1's reasoning
          'max_tokens': 150,
          'top_p': 0.9,
          'frequency_penalty': 0.5,
        }),
      );

      return _handleR1Response(response);
    } catch (e) {
      print('R1 Generation Error: $e');
      return null;
    }
  }

  String? _handleR1Response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final jsonResponse = json.decode(response.body);
        return jsonResponse['choices'][0]['message']['content'];
      case 429:
        return 'Too many requests. Please wait 20 seconds before trying again.';
      case 503:
        return 'Service temporarily unavailable. Try again shortly.';
      default:
        print('R1 API Error: ${response.statusCode} - ${response.body}');
        return 'Error: ${response.statusCode}';
    }
  }
}
