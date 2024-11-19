import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/services/isar_service.dart';
import 'package:flutter_application_1/models/course.dart';
import 'package:isar/isar.dart';

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
        title: const Text('Cursos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showCourseFormDialog(context, course: selectedCourse);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, selectedCourse!);
                  },
                ),
              ]
            : [],
      ),
      body: courses.isEmpty
          ? const Center(child: Text("No hay cursos disponibles"))
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return ListTile(
                  title: Text(course.titulo),
                  subtitle: Text('${course.professor}\n${course.description}'),
                  selected: course == selectedCourse,
                  onTap: () {
                    context.go('/signature/${course.id}');
                  },
                  onLongPress: () {
                    setState(() {
                      selectedCourse = course == selectedCourse ? null : course;
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCourseFormDialog(
              context); // Crear nuevo curso si no hay curso seleccionado
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Ventana emergente para agregar o editar un curso
  void _showCourseFormDialog(BuildContext context, {Course? course}) {
    // Si course no es nulo, es una edición; llenamos los campos con los valores actuales
    titleController.text = course?.titulo ?? '';
    professorController.text = course?.professor ?? '';
    descriptionController.text = course?.description ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(course == null ? 'Agregar un curso' : 'Editar curso'),
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
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final newCourse = Course()
                  // ..id = course?.id as Id // Mantener el id para la edición
                  ..titulo = titleController.text
                  ..professor = professorController.text
                  ..description = descriptionController.text;

                await isarService
                    .addCourse(newCourse); // Agrega o actualiza el curso

                titleController.clear();
                professorController.clear();
                descriptionController.clear();

                Navigator.of(context).pop();
                setState(() {
                  selectedCourse = null;
                });
                _loadCourses(); // Recargar cursos después de editar o agregar
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // Ventana de confirmación para eliminar un curso
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
