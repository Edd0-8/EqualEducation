import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/services/isar_service.dart';
import 'package:flutter_application_1/models/course.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final IsarService isarService = IsarService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController professorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<Course> courses = [];
  Course? selectedCourse;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final loadedCourses = await isarService.getCourses();
    setState(() {
      courses = loadedCourses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: selectedCourse != null
            ? [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    _showCourseFormDialog(context, course: selectedCourse);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, selectedCourse!);
                  },
                ),
              ]
            : [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bienvenido",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Image.asset(
                          'lib/assets/img/7.png',
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.go('/tasks');
                    },
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Mis Tareas',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Icon(Icons.check_circle, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Mis Cursos",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Selecciona o crea un nuevo curso",
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(thickness: 1, color: Colors.grey),
            Expanded(
              child: courses.isEmpty
                  ? const Center(
                      child: Text(
                          "   No hay cursos disponibles\nSeleccione '+' para crear un curso"))
                  : ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        final isSelected = course == selectedCourse;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                course.titulo,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Profesor: ${course.professor}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    'Descripción: ${course.description}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              tileColor: isSelected ? Colors.grey[300] : null,
                              onTap: () {
                                context.go('/signature/${course.id}');
                              },
                              onLongPress: () {
                                setState(() {
                                  selectedCourse =
                                      course == selectedCourse ? null : course;
                                });
                              },
                            ),
                            const Divider(thickness: 1, color: Colors.grey),
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
          _showCourseFormDialog(context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showCourseFormDialog(BuildContext context, {Course? course}) {
    titleController.text = course?.titulo ?? '';
    professorController.text = course?.professor ?? '';
    descriptionController.text = course?.description ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            course == null ? 'Agregar un curso' : 'Editar curso',
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
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: professorController,
                decoration: const InputDecoration(labelText: 'Profesor'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (course != null && course.id != null) {
                  // Si el curso existe, actualizamos
                  final updatedCourse = Course()
                    ..id = course.id // Mantener el id existente
                    ..titulo = titleController.text
                    ..professor = professorController.text
                    ..description = descriptionController.text;

                  await isarService
                      .updateCourse(updatedCourse); // Llamada para actualizar
                } else {
                  // Si no existe, creamos uno nuevo
                  final newCourse = Course()
                    ..titulo = titleController.text
                    ..professor = professorController.text
                    ..description = descriptionController.text;

                  await isarService
                      .addCourse(newCourse); // Llamada para crear
                }

                titleController.clear();
                professorController.clear();
                descriptionController.clear();

                Navigator.of(context).pop();
                setState(() {
                  selectedCourse = null;
                });
                _loadCourses();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar curso'),
          content: const Text(
              'Si eliminas este curso, también se eliminarán las asignaturas asociadas. ¿Estás seguro de que deseas eliminar el curso?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await isarService.deleteCourse(course.id);

                Navigator.of(context).pop();
                setState(() {
                  selectedCourse = null;
                });
                _loadCourses();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    professorController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
