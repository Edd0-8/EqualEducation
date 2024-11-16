import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'courses.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Lógica de migración en caso de que aumentemos la versión de la base de datos
        if (oldVersion < newVersion) {
          await _migrateDatabase(db, oldVersion, newVersion);
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE classes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseId INTEGER,
        name TEXT,
        FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE contents(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        classId INTEGER,
        name TEXT,
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _migrateDatabase(Database db, int oldVersion, int newVersion) async {
    // Ejemplo de migración: en caso de que necesites agregar una nueva columna o tabla.
    // if (oldVersion == 1 && newVersion == 2) {
    //   await db.execute('ALTER TABLE courses ADD COLUMN newColumn TEXT');
    // }
  }

  // MÉTODOS CRUD PARA "COURSES"

  // Obtener todos los cursos
  Future<List<Map<String, dynamic>>> getCourses() async {
    final db = await database;
    return await db.query('courses');
  }

  // Insertar un nuevo curso
  Future<void> insertCourse(String courseName) async {
    final db = await database;
    await db.insert(
      'courses',
      {'name': courseName},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Actualizar un curso existente
  Future<void> updateCourse(int id, String newName) async {
    final db = await database;
    await db.update(
      'courses',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar un curso
  Future<void> deleteCourse(int id) async {
    final db = await database;
    await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // MÉTODOS CRUD PARA "CLASSES"

  // Obtener clases por ID de curso
  Future<List<Map<String, dynamic>>> getClasses(int courseId) async {
    final db = await database;
    return await db.query(
      'classes',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
  }

  // Insertar una nueva clase
  Future<void> insertClass(String className, int courseId) async {
    final db = await database;
    await db.insert(
      'classes',
      {
        'name': className,
        'courseId': courseId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Actualizar una clase
  Future<void> updateClass(int id, String newName) async {
    final db = await database;
    await db.update(
      'classes',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar una clase
  Future<void> deleteClass(int id) async {
    final db = await database;
    await db.delete(
      'classes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // MÉTODOS CRUD PARA "CONTENTS"

  // Obtener contenidos por ID de clase
  Future<List<Map<String, dynamic>>> getContents(int classId) async {
    final db = await database;
    return await db.query(
      'contents',
      where: 'classId = ?',
      whereArgs: [classId],
    );
  }

  // Insertar nuevo contenido
  Future<void> insertContent(String contentDescription, int classId) async {
    final db = await database;
    await db.insert(
      'contents',
      {
        'name': contentDescription,
        'classId': classId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Actualizar contenido
  Future<void> updateContent(int id, String newDescription) async {
    final db = await database;
    await db.update(
      'contents',
      {'name': newDescription},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar contenido
  Future<void> deleteContent(int id) async {
    final db = await database;
    await db.delete(
      'contents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}


