import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config.dart';

// Función para enviar el texto a OpenAI y recibir la respuesta
Future<String> sendToOpenAI(String text) async {
  try {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'), // URL de la API actualizada para 'chat/completions'
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAiApiKey', // Sustituye con tu clave API real
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'Actúa como un tutor amigable y didactico de inglés. Cuando el estudiante se equivoque en la pronunciación, corrígele, dile cómo debe decirlo y pídele que lo repita. Siempre habla en inglés. Corrige un máximo de dos veces por cada error de pronunciación. Después de tres correcciones, hazle una pregunta para continuar entrenando su pronunciación y mejorar su fluidez. No corrijas el texto escrito, solo enfócate en la forma en que el estudiante habla. Cuando lo hace bien ya no le pidas que repira nuevamente sino avanza y dale pregunta nueva para avanzar en el aprendizaje. No corrijas letras mayúsculas, signos de admiración, preguntas o comas.',
          },
          {'role': 'user', 'content': text}, // Aquí le pasas el texto que obtuviste del reconocimiento de voz
        ],
      }),
    );

    // Verifica el código de estado de la respuesta
    if (response.statusCode == 200) {
      // Si la respuesta es correcta, extraemos el contenido de la respuesta de OpenAI
      var data = json.decode(response.body);
      String message = data['choices'][0]['message']['content'];
      return message; // Devuelve la respuesta de OpenAI
    } else {
      // Si hay un error en la respuesta, imprimimos el código de error y el cuerpo de la respuesta
      print("Error: ${response.statusCode}");
      print("Response: ${response.body}");
      return 'Error al procesar la solicitud';
    }
  } catch (e) {
    // Si ocurre un error en la conexión o en la solicitud, se captura y se imprime el error
    print("Error al comunicarse con OpenAI: $e");
    return 'Error de conexión';
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

    @override
  void initState() {
    super.initState(); // Llama a la implementación base de initState
    _initTts(); // Llama a tu método de inicialización del TTS
  }

void _initTts() async {
  _flutterTts = FlutterTts();

  try {
    // Configura el idioma a inglés (EE.UU.)
    await _flutterTts.setLanguage("en-US");

    // Verifica las voces disponibles
    List<dynamic> voices = await _flutterTts.getVoices;
    print("Voces disponibles al principio: $voices");

    // Verifica si la voz 'en-us-x-tpf-local' está disponible
    if (voices.any((voice) => voice['name'] == 'en-us-x-tpf-local')) {
      await _flutterTts.setVoice({"name": "en-us-x-tpf-local", "locale": "en-US"});
      print(" Si esta con La voz 'en-us-x-tpf-local'");
      _flutterTts.speak("Hello. The peace be with you. I'm your English Teacher. Let's start!");  // Añadir una frase simple para probar

    } else {
      print("La voz 'en-us-x-tpf-local' no está disponible.");
    }

    // Configura los parámetros de la voz
    await _flutterTts.setSpeechRate(1.0);  // Velocidad normal
    await _flutterTts.setPitch(1.0);       // Tono normal
    await _flutterTts.setVolume(1.0);      // Volumen máximo

    // Si quieres forzar el motor de Google TTS
    await _flutterTts.setEngine("com.google.android.tts");

    print("El idioma inglés está disponible.");
  } catch (e) {
    print("El idioma inglés no está disponible.");
  }
}

  final stt.SpeechToText _speech = stt.SpeechToText();
  String _text = "Hello. The peace be with you. I'm your English Teacher. Let's start!";
  String _response = ''; // Variable to store ChatGPT's response
  bool _isListening = false;

  // Function to listen and process speech input
  void _listen() async {
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


            // Verifica las voces disponibles
            List<dynamic> voices = await _flutterTts.getVoices;
            print("Voces disponibles: $voices");

            // Verifica si la voz 'en-us-x-tpf-local' está disponible
            if (voices.any((voice) => voice['name'] == 'en-us-x-tpf-local')) {
              // Establece la voz seleccionada
              await _flutterTts.setVoice({"name": "en-us-x-tpf-local", "locale": "en-US"});
              print("Usando la voz 'en-us-x-tpf-local'");
            } else {
              print("La voz 'en-us-x-tpf-local' no está disponible.");
            }


            // Asegúrate de que los parámetros de voz están configurados correctamente
            await _flutterTts.setSpeechRate(0.5);  // Velocidad normal
            await _flutterTts.setPitch(1.0);       // Tono normal
            await _flutterTts.setVolume(1.0);      // Volumen máximo

 


            // Read the response aloud
            await _flutterTts.speak(chatGptResponse);


             print("'********************************************************************'");
             print("'********************************************************************' ${chatGptResponse}");

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

  // Function sending text to OpenAI
  Future<void> _sendToChatGPT(String userInput) async {
    final apiKey= openAiApiKey;
    const url = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo', 
        'messages': [
          {'role': 'system', 'content': 'Actúa como un tutor amigable y didactico de inglés. Cuando el estudiante se equivoque en la pronunciación, corrígele, dile cómo debe decirlo y pídele que lo repita. Siempre habla en inglés. Corrige un máximo de dos veces por cada error de pronunciación. Después de tres correcciones, hazle una pregunta para continuar entrenando su pronunciación y mejorar su fluidez. No corrijas el texto escrito, solo enfócate en la forma en que el estudiante habla. Cuando lo hace bien ya no le pidas que repira nuevamente sino avanza y dale pregunta nueva para avanzar en el aprendizaje. No corrijas letras mayúsculas, signos de admiración, preguntas o comas.'},
          {'role': 'user', 'content': userInput},
        ],
      }),
    );

 if (response.statusCode == 200) {
    print("Se encontro respuestaaaaaaaaaaaaaaaaaaaaaaaaaa");

  final data = jsonDecode(response.body);
  String chatGptResponse = data['choices'][0]['message']['content'];

  setState(() {
    _text = chatGptResponse; // Mostrar respuesta de ChatGPT
  });

  print("Se va a llamar a _speak con el siguiente texto: $chatGptResponse");
  _speak(chatGptResponse); // Convertir la respuesta de ChatGPT a voz
} else {
  setState(() {
    _text = "Ups: Error al comunicarse con OpenAI.";
  });

  print("Ups: Error al comunicarse con OpenAI. Código de estado: ${response.statusCode}");
}
  }

  // Convertir texto a voz

void _speak(String text) async {
    print("En funcion speaaaaaaaaaaaaaaaaaaaaaaaaak");

  // Verifica las voces disponibles
  List<dynamic> voices = await _flutterTts.getVoices;
  print("Voces disponibles: $voices");

  // Verifica si la voz 'en-us-x-tpf-local' está disponible
  if (voices.any((voice) => voice['name'] == 'en-us-x-tpf-local')) {
    // Establece la voz seleccionada
    await _flutterTts.setVoice({"name": "en-us-x-tpf-local", "locale": "en-US"});
    print("Usando la voz 'en-us-x-tpf-local'");
  } else {
    print("La voz 'en-us-x-tpf-local' no está disponible.");
  }


  // Asegúrate de que los parámetros de voz están configurados correctamente
  await _flutterTts.setSpeechRate(1.0);  // Velocidad normal
  await _flutterTts.setPitch(1.0);       // Tono normal
  await _flutterTts.setVolume(1.0);      // Volumen máximo

  // Hablar el texto
  await _flutterTts.speak(text);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Elixa English"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _text,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              iconSize: 50,
              onPressed: _listen, // Updated to use the new _listen() function
            ),
            SizedBox(height: 20),
            Text(
              _response,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
