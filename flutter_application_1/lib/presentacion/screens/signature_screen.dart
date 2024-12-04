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
  final TextEditingController nameController = TextEditingController();
  List<Signature> signatures = [];
  Signature? selectedSignature;

  @override
  void initState() {
    super.initState();
    _loadSignatures();
  }

  Future<void> _loadSignatures() async {
    final loadedSignatures =
        await isarService.getSignaturesByCourseId(widget.courseId);
    setState(() {
      signatures = loadedSignatures;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.go('/course');
          },
        ),
        actions: selectedSignature != null
            ? [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    _showSignatureFormDialog(context,
                        signature: selectedSignature);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmDeleteSignature(selectedSignature!);
                  },
                ),
              ]
            : [],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mis Clases",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Selecciona o crea una nueva clase",
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(thickness: 1, color: Colors.grey),
            Expanded(
              child: signatures.isEmpty
                  ? const Center(
                      child: Text(
                          "No hay clases creadas para este curso\nSeleccione '+' para registrar una clase"),
                    )
                  : ListView.builder(
                      itemCount: signatures.length,
                      itemBuilder: (context, index) {
                        final signature = signatures[index];
                        final formattedDate =
                            DateFormat('dd/MM/yyyy').format(signature.date);

                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                signature.name,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              subtitle: Text(
                                'Fecha: $formattedDate',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              selected: signature == selectedSignature,
                              selectedTileColor: Colors.grey[300],
                              onTap: () {
                                context.go(
                                    '/content/${widget.courseId}/${signature.id}');
                              },
                              onLongPress: () {
                                setState(() {
                                  selectedSignature =
                                      signature == selectedSignature
                                          ? null
                                          : signature;
                                });
                              },
                            ),
                            const Divider(
                              thickness: 1,
                              color: Colors.grey, // Línea divisoria
                              height: 1, // Espaciado entre las clases
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          _showSignatureFormDialog(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showSignatureFormDialog(BuildContext context, {Signature? signature}) {
    nameController.text = signature?.name ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            signature == null ? 'Agregar Clase' : 'Editar Clase',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black,
                ),
          ),
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
                    const SnackBar(
                        content: Text(
                            'Por favor, ingresa un nombre para la Clase.')),
                  );
                  return;
                }

                final updatedSignature = signature ?? Signature();
                updatedSignature
                  // ..id = signature.id
                  ..name = nameController.text
                  ..date = signature?.date ?? DateTime.now()
                  ..courseId = widget.courseId;

                if (signature == null) {
                  await isarService.addSignature(updatedSignature);
                } else {
                  await isarService.updateSignature(updatedSignature);
                }

                Navigator.of(context).pop();
                setState(() {
                  selectedSignature = null;
                });
                _loadSignatures();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSignature(Signature signature) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Clase'),
          content: const Text(
              'Si eliminas esta clase, también se eliminará el contenido relacionado. ¿Estás seguro de que deseas eliminarla?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await isarService.deleteSignatureWithContent(signature.id);
                Navigator.of(context).pop();
                setState(() {
                  selectedSignature = null;
                });
                _loadSignatures();
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
