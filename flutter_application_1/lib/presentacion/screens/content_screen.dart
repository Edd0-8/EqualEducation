import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:go_router/go_router.dart';

class ContentScreen extends StatefulWidget {
  final int courseId;
  final int signatureId;

  const ContentScreen({
    super.key,
    required this.courseId,
    required this.signatureId,
  });

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _transcribedText = '';

  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Lista para almacenar los mensajes

  // Inicializa el reconocimiento de voz
// Inicializa el reconocimiento de voz
// Inicializa el reconocimiento de voz
  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Status: $status');
        if (status == 'done' && _isListening) {
          // Si el reconocimiento termina pero el usuario no detuvo, reiniciar
          _startListening();
        }
        if (status == 'notListening') {
          // Actualiza el estado visual cuando el reconocimiento se detiene
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        print('Error: $error');
        setState(() {
          _isListening = false; // Asegurar que el botón vuelva a mostrar el estado correcto
        });
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
      });
      _startListening();
    } else {
      print('El reconocimiento de voz no está disponible');
    }
  }

  // Empieza a escuchar y transcribir
  void _startListening() {
    _speech.listen(
      onResult: (result) {
        setState(() {
          _transcribedText = result.recognizedWords;
          if (result.finalResult) {
            _messages.add({
              'text': _transcribedText,
              'isTranscribed': true,
            });
            _transcribedText = '';
          }
        });
      },
      localeId: 'es_ES', // Cambia según el idioma preferido
    );
  }

  // Detiene el reconocimiento de voz
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }


  // Envía un mensaje escrito
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': text,
          'isTranscribed': false, // Alineación izquierda para mensajes escritos
        });
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contenido'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/signature/${widget.courseId}'); // Vuelve a SignatureScreen
          },
        ),
      ),
      body: Column(
        children: [
          // Sección del chat
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length + (_isListening && _transcribedText.isNotEmpty ? 1 : 0), // Incluir mensaje transitorio
              reverse: true, // Mostrar los mensajes más recientes al final
              itemBuilder: (context, index) {
                // Mostrar texto transcrito en tiempo real
                if (_isListening && index == 0 && _transcribedText.isNotEmpty) {
                  return Align(
                    alignment: Alignment.centerRight, // Alineación derecha
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _transcribedText,
                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ),
                  );
                }

                // Mostrar mensajes transcritos o escritos
                final message = _messages[_messages.length - 1 - index + (_isListening && _transcribedText.isNotEmpty ? 1 : 0)];
                final isTranscribed = message['isTranscribed'];
                return Align(
                  alignment: isTranscribed ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: isTranscribed ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          // Barra de entrada de texto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () {
                    if (_isListening) {
                      _stopListening(); // Detiene el reconocimiento de voz
                    } else {
                      _initSpeech(); // Inicia el reconocimiento de voz
                    }
                  },
                  heroTag: null,
                  mini: true,
                  child: Icon(_isListening ? Icons.stop : Icons.mic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
