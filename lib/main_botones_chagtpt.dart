import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT Voz',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const VoiceChatScreen(),
    );
  }
}

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  late stt.SpeechToText _speech; // Para reconocimiento de voz
  late FlutterTts _tts; // Para síntesis de voz
  bool _isListening = false;
  String _spokenText = '';
  String _responseText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
  }

  // Función para iniciar el reconocimiento de voz
  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(onResult: (result) {
        setState(() {
          _spokenText = result.recognizedWords;
        });
      });
    }
  }

  // Función para detener el reconocimiento de voz
  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }

  // Función para enviar texto a la API de OpenAI
  Future<void> _sendMessageToChatGPT(String message) async {
    const apiKey = 'TU_API_KEY_DE_OPENAI'; // Reemplaza con tu clave de API
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': message}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _responseText = data['choices'][0]['message']['content'];
      });
      await _speakResponse(_responseText); // Leer la respuesta en voz alta
    } else {
      setState(() {
        _responseText = 'Error: ${response.statusCode}';
      });
    }
  }

  // Función para convertir texto en voz
  Future<void> _speakResponse(String text) async {
    await _tts.setLanguage('es-ES'); // Configura el idioma
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatGPT Voz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Habla con ChatGPT',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Estilo personalizado
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? 'Detener' : 'Hablar'),
            ),
            const SizedBox(height: 20),
            Text(
              'Tu mensaje: $_spokenText',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_spokenText.isNotEmpty) {
                  _sendMessageToChatGPT(_spokenText);
                }
              },
              child: const Text('Enviar a ChatGPT'),
            ),
            const SizedBox(height: 20),
            Text(
              'Respuesta de ChatGPT: $_responseText',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
