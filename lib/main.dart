import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'config.dart';
import 'colors.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer _audioPlayer = AudioPlayer();

class CustomColors {
  static const Color pinkFuchsia = Color.fromARGB(255, 184, 0, 101);
  static const Color blueGradientStart = Color.fromARGB(255, 57, 60, 238);
  static const Color blueGradientEnd = Color.fromARGB(255, 110, 3, 211);
}

// Función para enviar el texto a OpenAI y recibir la respuesta con historial
// Lista para mantener el historial de conversación
List<Map<String, String>> chatHistory = [
//{'role': 'system', 'content': 'Actúa como un tutor amigable y didactico de inglés. Cuando el estudiante se equivoque en la pronunciación, corrígele, dile cómo debe decirlo y pídele que lo repita. Siempre habla en inglés. Corrige un máximo de dos veces por cada error de pronunciación. Después de tres correcciones, hazle una pregunta para continuar entrenando su pronunciación y mejorar su fluidez. No corrijas el texto escrito, solo enfócate en la forma en que el estudiante habla. Cuando lo hace bien ya no le pidas que repira nuevamente sino avanza y dale pregunta nueva para avanzar en el aprendizaje. No corrijas letras mayúsculas, signos de admiración, preguntas o comas'},

  {
    "role": "system",
    "content":
//"""Actúa como un tutor de inglés amigable, didáctico y proactivo, diseñado para ayudar al estudiante a alcanzar la fluidez rápidamente. Tu objetivo es motivar al estudiante, mantenerlo practicando activamente y hacer que la experiencia sea dinámica y emocionante.
        """Eres un entrenador de inglés de  Elixa English Tutor,diseñado para ayudar a los usuarios a mejorar su comunicación de manera natural y fluida. 
Actúa como una persona nativa con paciencia, que conversa sin hacer que el usuario repita frases, sino guiándolo de forma amena y comprensible. 
Usa un lenguaje claro y adaptado al nivel del usuario. Corrige errores sutilmente dentro de la conversación, sin interrumpir el flujo natural. 
Haz preguntas para mantener la charla y motiva al usuario a expresarse con confianza. Tu tono es amigable, relajado y motivador.
Sigue estas reglas estrictamente:

1. Refuérzale que practicando contigo logrará hablar inglés con confianza en situaciones reales.
2. Usa un tono motivador y entusiasta con frases como: "You're doing amazing!", "Keep it up!", "I'm so proud of your progress!".
3. Toma la iniciativa en la conversación, sugiriendo frases, temas o palabras nuevas. No permitas que el estudiante dirija la sesión.
4. Corrige errores de pronunciación o gramática con entusiasmo y amabilidad. Por ejemplo: "Almost there! Try saying it like this: 'I love learning English.' Great! Now repeat it with me!".
5. Felicita después de cada corrección exitosa y continúa con un nuevo tema o pregunta: "Excellent work! Now, let's talk about your hobbies. What do you like to do in your free time?".
6. Nunca dejes largas pausas ni hagas preguntas abiertas. Guía la conversación para mantener fluidez e interés.
7. Introduce ejercicios variados, como completar frases, describir imágenes o practicar situaciones reales: "Imagine you're ordering coffee at a café. What would you say?".
8. Proporciona desafíos progresivos con vocabulario avanzado o estructuras más complejas si el estudiante domina un tema.
9. Nunca preguntes qué quiere practicar. Dirige tú la sesión introduciendo temas nuevos de forma natural.
10. Recuérdale constantemente que practicar contigo es la mejor manera de mejorar: "The more you practice, the closer you are to speaking like a native!".
9. Da instrucciones claras y evita respuestas largas o complejas para maximizar la práctica.
10. Si el estudiante habla en español, corrígelo amablemente con un tono de pregunta: "You mean, 'I want to learn English.'? Great try! Repeat after me.".
11. Varía los temas de conversación (saludos, hobbies, trabajo, viajes) y añade juegos como "completar frases" o "describir imágenes".
12. Asegúrate de que la sesión sea entretenida y evita pausas incómodas. Mantén al estudiante entusiasmado.
13. Evalúa las habilidades del estudiante y adapta preguntas y ejercicios según sus necesidades.
14. Si detectas errores frecuentes, ofrece explicaciones breves y ejemplos prácticos. Corrijelo de manera amena y conversacional.
15. Introduce nuevas palabras, frases o estructuras para retar al estudiante si notas fluidez en ciertos temas.
16. Siempre habla en inglés y guía activamente la conversación. No permitas que el estudiante tome la iniciativa.
17. Nunca preguntes si desea cambiar de tema; continúa con preguntas o ejercicios relacionados.
18. Mantén el flujo de la conversación sin pausas ni despedidas prematuras. Solo termina si el estudiante se despide explícitamente.
19. Al inicio de cada sesión, motiva al estudiante recordándole cuánto necesita practicar y cómo lograrás ayudarlo a mejorar rápidamente: "Welcome back! With consistent practice, you'll be speaking English fluently in no time. Let's begin!".
20. Después de felicitar por una respuesta correcta, continúa inmediatamente con una nueva pregunta o actividad: "Great job! Let's try another one. Can you tell me about your favorite food?".
20. Cuando hagas una correccion en ingles, dile, You mean "...Frase correcta..." o algo parecido como cuando alguien esta en otro pais tratando de hablar con gente nativa.
21. Si corriges no hagas otra pregunta, deja que el alumno se corrija.
22. No te despidas sin que el alumno se despida primero, procura poner interesante la sesion.
23. Haz la conversacion amena no corrijas tanto, solo corrije del tipo You mean 
22. Da respuestas cortas de maximo 17 palabras.
Recuerda: tu objetivo es ser un tutor motivador y proactivo, asegurando que el estudiante se sienta confiado y motivado. ¡Hazlo divertido y emocionante!"""
  }
];

Future<String> sendToOpenAI(String text) async {
  try {
    print("Chathistory: $chatHistory");
    if (chatHistory.length > 20) {
      chatHistory =
          [chatHistory.first] + chatHistory.sublist(chatHistory.length - 19);
    }

// Agrega el nuevo mensaje del usuario al historial
    chatHistory.add({'role': 'user', 'content': text});

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAiApiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': chatHistory, // Enviar todo el historial de mensajes
      }),
    );

    // Verifica si la respuesta es exitosa
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final assistantResponse = data['choices'][0]['message']['content'];

      // Agrega la respuesta del asistente al historial
      chatHistory.add({'role': 'assistant', 'content': assistantResponse});
      for (var message in chatHistory) {
        print("[${message['role']}] ${message['content']}");
      }
      return assistantResponse; // Devuelve la respuesta del asistente
    } else {
      throw Exception('Error al comunicarse con OpenAI: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
    return 'Lo siento, ocurrió un error.';
  }
}

// Función que maneja el resultado del reconocimiento de voz
void onSpeechResult(String text) async {
  print("Texto transcrito: $text");
  try {
    // Llamamos a la función para enviar el texto a OpenAI y obtener la respuesta
    String response = await sendToOpenAI(text);
    print("Respuesta de ChatGPT: $response");
    // Aquí puedes hacer algo con la respuesta, como reproducirla usando Text-to-Speech
  } catch (e) {
    print("Ups: Error al comunicarse con OpenAI: $e");
  }
}

void main() {
  runApp(MyApp());
}

void requestPermissions() async {
// Solicitar permiso para grabar audio
  var status = await Permission.microphone.request();

  if (status.isGranted) {
// El permiso fue otorgado
    print("Micrófono permitido");
  } else {
// El permiso no fue otorgado
    print("Micrófono no permitido");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatGPT Voice Interaction',
      home: ChatScreen(),
      theme: ThemeData(
        primaryColor: CustomColors.pinkFuchsia,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late FlutterTts _flutterTts;
  late VideoPlayerController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState(); // Llama a la implementación base de initState
    _controller = VideoPlayerController.asset('assets/vida2.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
    _initTts(); // Llama a tu método de inicialización del TTS
  }

  void _initTts() async {
    print("Inicializando TTS con OpenAI...");
    await _speak(
        "Practicing with Elixa Tutor English will help you speak English fluently in no time! Let's get started");


  }

  final stt.SpeechToText _speech = stt.SpeechToText();
  String _text =
      "Practicing with Elixa Tutor English will help you speak English fluently in no time! Let's get started!";
  String _response = ''; // Variable to store ChatGPT's response
  bool _isListening = false;
  bool _isBotSpeaking = false;

  Future<void> processAndSpeakResponse(
      String userText, Future<String> Function(String) sendToOpenAI) async {
    if (userText.isNotEmpty) {
      String chatGptResponse = await sendToOpenAI(userText);
      print("Respuesta de OpenAI: $chatGptResponse");
      await _speak(chatGptResponse);
    }
  }

  Future<void> handleSpeechRecognition(String recognizedText,
      Future<String> Function(String) sendToOpenAI) async {
    if (recognizedText.isNotEmpty) {
      print("Texto reconocido: $recognizedText");
      await processAndSpeakResponse(recognizedText, sendToOpenAI);
    }
  }

// Function to listen and process speech input
  void _listen() async {
    _isBotSpeaking = false;

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print("Mic status: $val");
          if (val == "notListening") {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (val) {
          print("Mic error: $val");
          setState(() {
            _isListening = false;
          });
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
        });

        _speech.listen(onResult: (val) async {
          setState(() {
            _text = val.recognizedWords;
          });

          if (!_speech.isListening) {
            // Send recognized text to OpenAI and process the response
            String chatGptResponse = await sendToOpenAI(_text);
            setState(() {
              _response = chatGptResponse;
            });

            // Read the response aloud
            await _speak(chatGptResponse);

            print(
                "'********************************************************************'");
            print(
                "'********************************************************************' ${chatGptResponse}");
          }
        });
      } else {
        print("Microphone is not available.");
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }

// Convertir texto a voz

//api key hailuo eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJHcm91cE5hbWUiOiJFbGlzYSBSaXZhZGVuZWlyYSIsIlVzZXJOYW1lIjoiRWxpc2EgUml2YWRlbmVpcmEiLCJBY2NvdW50IjoiIiwiU3ViamVjdElEIjoiMTg4MzE3MjYxODgwNzI4NDA4MSIsIlBob25lIjoiIiwiR3JvdXBJRCI6IjE4ODMxNzI2MTg4MDMwODk3NzciLCJQYWdlTmFtZSI6IiIsIk1haWwiOiJlcml2YWRlbmVpcmFxQGdtYWlsLmNvbSIsIkNyZWF0ZVRpbWUiOiIyMDI1LTAyLTAyIDAwOjU0OjMxIiwiVG9rZW5UeXBlIjoxLCJpc3MiOiJtaW5pbWF4In0.U_QOpmfBfMQNgasyFaXjSS8UWnAunTlS_8VVg4H5T_42Q5vWNNMd4A_-fjwoOtrU9gmxvFRw3rjeiNVoN3riRmWpfBeLO5I2RRkNGZZv-fr6aVc1CgbU3L_B83QAMJFVS0pFso_kOYMjy_gUclAfQLcrbHFrUJrytW14Z828WmqUD8pIhPUoVInBqHEg3XajqcHK2pulDP3JZmKoZz15fH1nmAncSdRU89947fXCcsrjfR-AxSDscvXbRFBUGsrMVEsrU8_jgHUX7yVXtq120WcFnOT9c3YpllFWooQ8KdGM-ZQMXCPI6F0eUOiISNgVdOI0R3iZR3y49JBTbYGrQg
  Future<void> _speak(String text) async {
    final String apiUrl = "https://api.openai.com/v1/audio/speech";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: json.encode({
          'model': 'tts-1',
          'voice': 'nova', // Puedes cambiar a "echo", "nova", etc.
          'input': text,
        }),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final String audioUrl = 'data:audio/mpeg;base64,${base64Encode(bytes)}';
        await _audioPlayer.play(UrlSource(audioUrl));
      } else {
        print("Error al obtener el audio: ${response.body}");
      }
    } catch (e) {
      print("Error en la solicitud TTS: $e");
    }
  }

  void _simulateBotResponse() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isBotSpeaking = true;
        _response = "Hello! How can I assist you today?";
        _text = "Tap the microphone to speak again.";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Elixa English"),
        backgroundColor: CustomColors.pinkFuchsia,
      ),
      body: Stack(
        children: [
          // Video de fondo
          Positioned.fill(
            child: _controller.value.isInitialized
                ? VideoPlayer(_controller)
                : Center(child: CircularProgressIndicator()),
          ),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 182, 8, 109),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _listen,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? Colors.greenAccent
                              : (_isBotSpeaking
                                  ? Colors.orangeAccent
                                  : Colors.blueAccent),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _isListening
                                  ? Colors.green
                                  : (_isBotSpeaking
                                      ? Colors.orange
                                      : Colors.blue),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isListening ? Icons.mic : Icons.mic_off,
                        size: 50,
                        color: const Color.fromARGB(255, 234, 242, 255),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  _response,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: const Color.fromARGB(255, 212, 7, 76),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
