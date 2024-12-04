import 'package:file_picker/file_picker.dart'; // Manejo de archivos
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/block.dart';
import 'package:flutter_application_1/models/content.dart';
import 'package:flutter_application_1/services/isar_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/widgets/video_player_widget.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

// Clase para manejar los mensajes en el chat
class ChatMessage {
  final int? id;
  final String? text;
  final File? file;
  final String blockType; // "text", "image", "video", "AudioText", "document"
  final bool isTranscribed;

  ChatMessage({
    this.id,
    this.text,
    this.file,
    required this.blockType,
    this.isTranscribed = false,
  });
}

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
  // ===========================================================
  // Variables principales y servicios
  // ===========================================================
  final IsarService _isarService = IsarService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _messageController = TextEditingController();

  List<ChatMessage> _messages = [];
  bool _isListening = false;
  Content? _currentContent;

  @override
  void initState() {
    super.initState();
    _initTts();
    _ensureContentExists(); // Verifica o crea el contenido asociado
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  // ===========================================================
  // Métodos para texto a audio (FlutterTTS)
  // ===========================================================
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  // ===========================================================
  // Métodos para audio a texto (Speech-to-Text)
  // ===========================================================
  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        setState(() {
          _isListening = status == 'listening';
        });
      },
      onError: (error) {
        print('Error: $error');
        setState(() {
          _isListening = false;
        });
      },
    );

    if (available) {
      _startListening();
    } else {
      print('El reconocimiento de voz no está disponible');
    }
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      setState(() {
        _isListening = true;
        _messages.insert(
          0,
          ChatMessage(
            text: '',
            blockType: 'AudioText',
            isTranscribed: true,
          ),
        );
      });
    }

    await _speech.listen(
      onResult: (result) async {
        setState(() {
          // Actualizar el texto temporal en tiempo real
          _messages[0] = ChatMessage(
            text: result.recognizedWords,
            blockType: 'AudioText',
            isTranscribed: true,
          );

          if (result.finalResult) {
            _saveBlock('AudioText', result.recognizedWords);
            _isListening = false; // Detener el estado de escucha
          }
        });
      },
      localeId: 'es_ES',
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // ===========================================================
  // Métodos para manejar contenido y bloques
  // ===========================================================
  Future<void> _ensureContentExists() async {
    final existingContent =
        await _isarService.getContentBySignatureId(widget.signatureId);

    if (existingContent != null) {
      setState(() {
        _currentContent = existingContent;
      });
      await _loadBlocks();
    } else {
      final newContent = Content()
        ..signatureId = widget.signatureId
        ..name = "Contenido para Signature ${widget.signatureId}"
        ..description = "Descripción automática";
      await _isarService.addContent(newContent);
      setState(() {
        _currentContent = newContent;
      });
    }
  }

  Future<void> _loadBlocks() async {
    if (_currentContent == null) return;

    final blocks = await _isarService.getBlocksByContentId(_currentContent!.id);
    setState(() {
      _messages = blocks.map((block) {
        if (block.blockType == 'text') {
          return ChatMessage(
            id: block.id,
            text: block.blockContent,
            blockType: 'text',
          );
        } else if (block.blockType == 'image') {
          final file = File(block.blockContent);
          return ChatMessage(
            id: block.id,
            file: file,
            blockType: block.blockType,
          );
        } else if (block.blockType == 'video') {
          final file = File(block.blockContent);
          return ChatMessage(
            id: block.id,
            file: file,
            blockType: 'video',
          );
        } else if (block.blockType == 'document') {
          final file = File(block.blockContent);
          return ChatMessage(
            id: block.id,
            file: file,
            blockType: 'document',
          );
        } else if (block.blockType == 'AudioText') {
          return ChatMessage(
            id: block.id,
            text: block.blockContent,
            blockType: 'AudioText',
            isTranscribed: true,
          );
        }
        return ChatMessage(
          id: block.id,
          blockType: 'unknown',
        );
      }).toList();
    });
  }

  Future<void> _saveBlock(String blockType, String blockContent) async {
    if (_currentContent == null) return;

    final newBlock = Block()
      ..contentId = _currentContent!.id
      ..blockType = blockType
      ..blockContent = blockContent
      ..timestamp = DateTime.now(); // Agregar el campo obligatorio
    await _isarService.addBlock(newBlock);
    _loadBlocks(); // Recarga los bloques para reflejar cambios
  }

  // ===========================================================
  // Métodos para adjuntar archivos
  // ===========================================================
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final file = File(result.files.single.path!);
        await _saveBlock('document', file.path);
      }
    } catch (e) {
      print("Error al seleccionar archivo: $e");
    }
  }

  // ===========================================================
  // Métodos para manejar medios (imágenes)
  // ===========================================================
  Future<File> _saveFileToLocalStorage(XFile file) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String path = '${appDir.path}/${file.name}';
    return File(file.path).copy(path);
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final File savedImage = await _saveFileToLocalStorage(photo);
        await _saveBlock('image', savedImage.path);
      }
    } catch (e) {
      print("Error al capturar foto: $e");
    }
  }

  // ===========================================================
  // Métodos para manejar medios (videos)
  // ===========================================================

  Future<File> _generateThumbnail(String videoPath) async {
    final String thumbnailPath = (await getTemporaryDirectory()).path;
    final String? filePath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: thumbnailPath,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 150, // Altura máxima de la miniatura
      quality: 75,
    );
    return File(filePath!);
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        final File savedVideo = await File(video.path).copy(
            '${(await getApplicationDocumentsDirectory()).path}/${video.name}');
        await _saveBlock('video', savedVideo.path);
      }
    } catch (e) {
      print("Error al grabar video: $e");
    }
  }

  // ===========================================================
  // Métodos para enviar mensajes
  // ===========================================================
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _messageController.clear();
      await _saveBlock('text', text);
      _speak(text);
    }
  }

  // ===========================================================
  // Construcción de la interfaz
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contenido'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/signature/${widget.courseId}');
          },
        ),
        actions: [
          IconButton(
            onPressed: _pickFile,
            icon: const Icon(Icons.attach_file),
          ),
          IconButton(
            onPressed: _capturePhoto,
            icon: const Icon(Icons.camera_alt),
          ),
          IconButton(
            onPressed: _recordVideo,
            icon: const Icon(Icons.videocam),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              reverse: false,
              itemBuilder: (context, index) {
                final message = _messages[index];

                // ===========================================================
                // Validación para archivos adjuntos
                // ===========================================================
                if (message.file != null) {
                  // ===========================================================
                  // Validación para documentos
                  // ===========================================================
                  if (message.blockType == 'document') {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[300], // Fondo gris
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file, size: 30),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (File(message.file!.path).existsSync()) {
                                    OpenFilex.open(message.file!.path);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Archivo no encontrado.')),
                                    );
                                  }
                                },
                                child: Text(
                                  message.file!.path.split('/').last,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // ===========================================================
                  // Validación para videos
                  // ===========================================================
                  if (message.blockType == 'video') {
                    // ===========================================================
                    // Validación: Si el archivo de video existe
                    // ===========================================================
                    if (File(message.file!.path).existsSync()) {
                      return Padding(
                        // =======================================================
                        // Padding para margen alrededor del video
                        // =======================================================
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: FutureBuilder<Uint8List?>(
                          future: VideoThumbnail.thumbnailData(
                            video: message.file!.path,
                            imageFormat: ImageFormat.PNG,
                            maxWidth: 170, // Ancho máximo de la miniatura
                            quality: 75,
                          ),
                          builder: (context, snapshot) {
                            // ===================================================
                            // Estado: Mientras se genera la miniatura (Cargando)
                            // ===================================================
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 200,
                                  height: 120,
                                  color: Colors.black12,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              );
                            }
                            // ===================================================
                            // Estado: Miniatura generada con éxito
                            // ===================================================
                            else if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData &&
                                snapshot.data != null) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Scaffold(
                                          appBar: AppBar(
                                            title: const Text(
                                                "Reproduciendo video"),
                                          ),
                                          body: Center(
                                            child: VideoPlayerScreen(
                                                filePath: message.file!.path),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // =================================================
                                      // Miniatura del video
                                      // =================================================
                                      Image.memory(
                                        snapshot.data!,
                                        width: 200,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                      // =================================================
                                      // Icono de reproducción centrado
                                      // =================================================
                                      const Icon(
                                        Icons.play_circle_outline,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            // ===================================================
                            // Estado: Error al generar la miniatura
                            // ===================================================
                            else {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 200,
                                  height: 120,
                                  color: Colors.black12,
                                  child: const Center(
                                    child: Text(
                                      "Error al cargar video",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }
                    // ===========================================================
                    // Manejo: Si el archivo de video no existe
                    // ===========================================================
                    else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 200,
                            height: 120,
                            color: Colors.black12,
                            child: const Center(
                              child: Text(
                                "Archivo no encontrado",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }

                  // ===========================================================
                  // Validación para imágenes
                  // ===========================================================
                  else if (message.blockType == 'image') {
                    if (File(message.file!.path).existsSync()) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0), // Margen agregado
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(),
                                    body: Center(
                                      child: Image.file(message.file!),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Image.file(
                              message.file!,
                              width: 150,
                              height: 150, // Tamaño ajustado
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Imagen no disponible.',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                  }
                }

                // ===========================================================
                // Validación para mensajes de texto y transcripciones
                // ===========================================================
                return Align(
                  alignment: message.isTranscribed
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: message.isTranscribed
                          ? Colors.blue[200]
                          : Colors.grey[300], // Fondo azul o gris
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message.text ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
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
                      _stopListening();
                    } else {
                      _initSpeech();
                    }
                  },
                  heroTag: false,
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
