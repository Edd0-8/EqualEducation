import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContentScreen extends StatelessWidget {
  final int courseId;
  final int signatureId;

  const ContentScreen({super.key, required this.courseId, required this.signatureId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contenido'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navegar de regreso a SignatureScreen con el parámetro courseId
            context.go('/signature/$courseId');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200], // Fondo gris para simular un chat
              child: const Center(
                child: Text('Aquí se mostrarán los mensajes'),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
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
                  onPressed: () {
                    // Acción del botón de micrófono
                  },
                  mini: true, // Tamaño pequeño para el botón
                  child: const Icon(Icons.mic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
