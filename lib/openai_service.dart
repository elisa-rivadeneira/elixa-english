// lib/openai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> generateResponse(String prompt) async {
  const apiKey = 'k-proj-izRRIjd53ylOCHwp_I8WK3w8EQyhWkbp89GQk4l3zl009F7k9MWfHTvaDQ6kCrcPZw-HMZJJG9T3BlbkFJ_kbvEdF2MPXw5GCgkKAuAlQUeel05liOV8-Ps3x7OUWphPVqU4h5risvVsEXy0MVPAbddB2O8A';  // Reemplaza con tu clave API
  const url = 'https://api.openai.com/v1/chat/completions';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo', // O el modelo que prefieras
      'messages': [
        {'role': 'system', 'content': 'Actúa como un tutor de inglés amigable.'},
        {'role': 'user', 'content': prompt},
      ],
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  } else {
    throw Exception('Error al comunicarse con OpenAI: ${response.body}');
  }
}
