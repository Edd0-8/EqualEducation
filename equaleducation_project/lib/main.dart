import 'package:flutter/material.dart';
import 'db/database_helper.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

//Pagina Principal
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Column(
                children: const [
                  Text(
                    'Una nueva forma',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'de Aprender',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CoursesScreen()),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Comenzar',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




//Pagina donde se agregan Cursos
class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _courseController = TextEditingController();
  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final data = await DatabaseHelper().getCourses();
    setState(() {
      _courses = data;
    });
  }

  Future<void> _addCourse() async {
    if (_courseController.text.isNotEmpty) {
      await DatabaseHelper().insertCourse(_courseController.text);
      _courseController.clear();
      _loadCourses();  // Recargar la lista de cursos
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _courseController,
              decoration: InputDecoration(
                labelText: 'Course Name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addCourse,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return ListTile(
                  title: Text(course['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassesScreen(courseId: course['id']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}






//Pagina de la Clase
class ClassesScreen extends StatefulWidget {
  final int courseId;
  ClassesScreen({required this.courseId});

  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final TextEditingController _classController = TextEditingController();
  List<Map<String, dynamic>> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final data = await DatabaseHelper().getClasses(widget.courseId);
    setState(() {
      _classes = data;
    });
  }

  Future<void> _addClass() async {
    if (_classController.text.isNotEmpty) {
      await DatabaseHelper().insertClass(_classController.text, widget.courseId);
      _classController.clear();
      _loadClasses();  // Recargar la lista de clases
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes for Course ID: ${widget.courseId}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _classController,
              decoration: InputDecoration(
                labelText: 'Class Name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addClass,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                final classItem = _classes[index];
                return ListTile(
                  title: Text(classItem['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContentsScreen(classId: classItem['id']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//Pagina del Contenido de la Clase
class ContentsScreen extends StatefulWidget {
  final int classId;
  ContentsScreen({required this.classId});

  @override
  _ContentsScreenState createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen> {
  final TextEditingController _contentController = TextEditingController();
  List<Map<String, dynamic>> _contents = [];

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    final data = await DatabaseHelper().getContents(widget.classId);
    setState(() {
      _contents = data;
    });
  }

  Future<void> _addContent() async {
    if (_contentController.text.isNotEmpty) {
      await DatabaseHelper().insertContent(_contentController.text, widget.classId);
      _contentController.clear();
      _loadContents();  // Recargar la lista de contenidos
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contents for Class ID: ${widget.classId}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content Description',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addContent,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _contents.length,
              itemBuilder: (context, index) {
                final content = _contents[index];
                return ListTile(
                  title: Text(content['description']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



