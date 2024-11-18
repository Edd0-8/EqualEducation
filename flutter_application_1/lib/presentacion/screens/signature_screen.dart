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
        title: const Text('Asignaturas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              context.go('/course');
            }
          },
        ),
      ),
      body: signatures.isEmpty
          ? const Center(child: Text("No hay asignaturas para este curso"))
          : ListView.builder(
              itemCount: signatures.length,
              itemBuilder: (context, index) {
                final signature = signatures[index];
                final formattedDate = DateFormat('dd/MM/yyyy').format(signature.date);

                return ListTile(
                  title: Text(signature.name),
                  subtitle: Text('Fecha: $formattedDate'),
                  onTap: () {
                    // Navegar a la pantalla de Content
                    context.go('/content', extra: signature.id);
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
          title: Text('Opciones de Asignatura'),
          content: Text('¿Qué deseas hacer con esta asignatura?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditSignatureFormDialog(context, signature); // Editar
              },
              child: const Text('Editar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmDeleteSignature(signature); // Eliminar
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
          title: Text('Eliminar Asignatura'),
          content: Text('¿Estás seguro de que deseas eliminar esta asignatura?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await isarService.deleteSignature(signature.id);
                Navigator.of(context).pop(); // Cierra el diálogo
                _loadSignatures(); // Recargar las asignaturas
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
          title: const Text('Editar Asignatura'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Asignatura'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  signature.name = nameController.text; // Actualiza el nombre
                  await isarService.updateSignature(signature);
                  Navigator.of(context).pop(); // Cierra el diálogo
                  _loadSignatures(); // Recargar las asignaturas
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
          title: const Text('Agregar asignatura'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Asignatura'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingresa un nombre para la asignatura.')),
                  );
                  return;
                }

                final signature = Signature()
                  ..name = nameController.text
                  ..date = DateTime.now()
                  ..courseId = widget.courseId;

                await isarService.addSignature(signature);
                Navigator.of(context).pop(); // Cierra el diálogo
                _loadSignatures(); // Recargar las asignaturas
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
