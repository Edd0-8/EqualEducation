import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/isar_service.dart';
import 'package:flutter_application_1/models/signature.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SignatureScreen extends StatefulWidget {
  final int courseId; // ID del curso seleccionado

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
                // Formato de fecha amigable
                final formattedDate = DateFormat('dd/MM/yyyy').format(signature.date);
                return ListTile(
                  title: Text(signature.name),
                  subtitle: Text('Fecha: $formattedDate'),
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

  // Ventana emergente para agregar una nueva asignatura
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
                Navigator.of(context).pop(); // Cierra la ventana emergente
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, ingresa un nombre para la asignatura.'),
                    ),
                  );
                  return;
                }

                // Crear la asignatura con la fecha actual y el courseId asignado
                final signature = Signature()
                  ..name = nameController.text
                  ..date = DateTime.now() // Fecha actual
                  ..courseId = widget.courseId;

                await isarService.addSignature(signature);
                Navigator.of(context).pop(); // Cierra la ventana emergente
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
