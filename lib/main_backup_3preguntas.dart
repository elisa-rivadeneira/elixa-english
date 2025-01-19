import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutor de Inglés',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NameScreen(),
    );
  }
}

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  String? name;
  String? reason;
  String? level;

  void navigateToNextScreen() {
    if (name != null && name!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReasonScreen(name: name!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutor de Inglés')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ingresa tu nombre:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Tu nombre'),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: navigateToNextScreen,
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReasonScreen extends StatelessWidget {
  final String name;

  const ReasonScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutor de Inglés')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hola, $name. ¿Por qué quieres aprender inglés?',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LevelScreen(
                      name: name,
                      reason: 'Para trabajar',
                    ),
                  ),
                );
              },
              child: const Text('Para trabajar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LevelScreen(
                      name: name,
                      reason: 'Para viajar',
                    ),
                  ),
                );
              },
              child: const Text('Para viajar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LevelScreen(
                      name: name,
                      reason: 'Para conocer personas de otros países',
                    ),
                  ),
                );
              },
              child: const Text('Para conocer personas de otros países'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LevelScreen(
                      name: name,
                      reason: 'Para estudiar',
                    ),
                  ),
                );
              },
              child: const Text('Para estudiar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LevelScreen(
                      name: name,
                      reason: 'Por curiosidad',
                    ),
                  ),
                );
              },
              child: const Text('Por curiosidad'),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelScreen extends StatelessWidget {
  final String name;
  final String reason;

  const LevelScreen({super.key, required this.name, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutor de Inglés')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gracias, $name. ¿Cuál es tu nivel de inglés?',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showSummary(context, name, reason, 'No entiendo nada');
              },
              child: const Text('No entiendo nada'),
            ),
            ElevatedButton(
              onPressed: () {
                _showSummary(
                    context, name, reason, 'Puedo preguntar sobre precios y comprar');
              },
              child: const Text('Puedo preguntar sobre precios y comprar'),
            ),
            ElevatedButton(
              onPressed: () {
                _showSummary(context, name, reason, 'Puedo entablar conversaciones básicas');
              },
              child: const Text('Puedo entablar conversaciones básicas'),
            ),
            ElevatedButton(
              onPressed: () {
                _showSummary(
                    context, name, reason, 'Puedo expresar todo lo que siento y pienso');
              },
              child: const Text('Puedo expresar todo lo que siento y pienso'),
            ),
            ElevatedButton(
              onPressed: () {
                _showSummary(
                    context, name, reason, 'Me desenvuelvo con total normalidad');
              },
              child: const Text('Me desenvuelvo con total normalidad'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSummary(BuildContext context, String name, String reason, String level) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resumen'),
        content: Text(
          'Nombre: $name\n'
          'Razón para aprender inglés: $reason\n'
          'Nivel de inglés: $level',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
