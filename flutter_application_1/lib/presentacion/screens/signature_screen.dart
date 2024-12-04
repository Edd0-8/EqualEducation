import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/isar_service.dart';
import 'package:flutter_application_1/models/signature.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SignatureScreen extends StatefulWidget {
  final int courseId;

  const SignatureScreen({super.key, required this.courseId});

  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final IsarService isarService = IsarService();
  List<Signature> signatures = [];

  @override
  void initState() {
    super.initState();
    _loadSignatures();
  }

  Future<void> _loadSignatures() async {
    final loadedSignatures = await isarService.getSignaturesByCourseId(widget.courseId);
    setState(() {
      signatures = loadedSignatures;
      print('Asignaturas cargadas ${signatures.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clase'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/course'); // Regresa a la pantalla de cursos
          },
        ),
      ),
      body: signatures.isEmpty
          ? const Center(child: Text("No hay clases creadas para este curso\nSeleccione '+' para registrar una clase"))
          : ListView.builder(
              itemCount: signatures.length,
              itemBuilder: (context, index) {
                final signature = signatures[index];
                final formattedDate = DateFormat('dd/MM/yyyy').format(signature.date);

                return ListTile(
                  title: Text(signature.name),
                  subtitle: Text('Fecha: $formattedDate'),
                  onTap: () {
                    // Navegar a ContentScreen con courseId y signatureId
                    context.go('/content/${widget.courseId}/${signature.id}');
                  },
                  onLongPress: () {
                    _showOptionsDialog(context, signature);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSignatureFormDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Dialog para seleccionar editar o eliminar
  void _showOptionsDialog(BuildContext context, Signature signature) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Opciones de Clase'),
          content: const Text('¿Qué deseas hacer con esta clase?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditSignatureFormDialog(context, signature);
              },
              child: const Text('Editar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmDeleteSignature(signature);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  // Confirmación para eliminar asignatura
  void _confirmDeleteSignature(Signature signature) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Clase'),
          content: const Text('¿Estás seguro de que deseas eliminar esta clase?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await isarService.deleteSignature(signature.id);
                Navigator.of(context).pop();
                _loadSignatures();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // Dialog para editar asignatura
  void _showEditSignatureFormDialog(BuildContext context, Signature signature) {
    final TextEditingController nameController = TextEditingController(text: signature.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Clase'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Clase'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  signature.name = nameController.text;
                  await isarService.updateSignature(signature);
                  Navigator.of(context).pop();
                  _loadSignatures();
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // Dialog para agregar nueva asignatura
  void _showSignatureFormDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Clase'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Clase'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingresa un nombre para la Clase.')),
                  );
                  return;
                }

                final signature = Signature()
                  ..name = nameController.text
                  ..date = DateTime.now()
                  ..courseId = widget.courseId;

                await isarService.addSignature(signature);
                Navigator.of(context).pop();
                _loadSignatures();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
