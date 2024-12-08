import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/isar_service.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:go_router/go_router.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final IsarService isarService = IsarService();
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await isarService.getTasks();
    setState(() {
      tasks = loadedTasks;
    });
  }

  void _showTaskFormDialog({Task? task}) {
    final TextEditingController taskController =
        TextEditingController(text: task?.descripcion);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task == null ? 'Agregar Tarea' : 'Editar Tarea'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: 'Tarea'),
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
                if (taskController.text.isNotEmpty) {
                  final newTask = task ?? Task();
                  newTask.descripcion = taskController.text;
                  newTask.estado = task?.estado ?? false;

                  if (task == null) {
                    await isarService.addTask(newTask);
                  } else {
                    await isarService.updateTask(newTask);
                  }

                  Navigator.of(context).pop();
                  _loadTasks();
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Tarea'),
          content: const Text('¿Estás seguro de que deseas eliminar esta tarea?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await isarService.deleteTask(task.id);
                Navigator.of(context).pop();
                _loadTasks();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
          leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.go('/course');
          },
        ),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text("No hay tareas\nPresiona '+' para agregar una."),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(
                    task.descripcion,
                    style: TextStyle(
                      decoration: task.estado
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: Icon(
                    task.estado ? Icons.check_circle : Icons.circle_outlined,
                    color: task.estado ? Colors.green : Colors.grey,
                  ),
                  onTap: () async {
                    task.estado = !task.estado;
                    await isarService.updateTask(task);
                    _loadTasks();
                  },
                  onLongPress: () {
                    _confirmDeleteTask(task);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTaskFormDialog();
        },
        backgroundColor: Colors.black,
        child: const Icon(
          color: Colors.white,
          Icons.add),
      ),
    );
  }
}
