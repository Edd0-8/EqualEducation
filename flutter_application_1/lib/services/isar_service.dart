import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_1/models/course.dart';
import 'package:flutter_application_1/models/signature.dart';
import 'package:flutter_application_1/models/content.dart';
import 'package:flutter_application_1/models/block.dart';

class IsarService {
  static Isar? _db; //Variable que almacena la instancia de Isar

  //Apertura de Base de Datos y Validacion
  Future<Isar> _openDB() async {
    if (_db != null){
      return _db!;
    }

    final dir = await getApplicationDocumentsDirectory();
    _db = await Isar.open(
      [CourseSchema, SignatureSchema, ContentSchema, BlockSchema],
      directory: dir.path,
    );

    return _db!;
  }

  

  // CRUD for Courses
  // Método para agregar un curso
  Future<void> addCourse(Course course) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.courses.put(course);
    });
  }

  // Método para obtener todos los cursos
  Future<List<Course>> getCourses() async {
    final isar = await _openDB();
    return await isar.courses.where().findAll();
  }

  // Método para obtener un curso específico por ID
  Future<Course?> getCourseById(int id) async {
    final isar = await _openDB();
    return await isar.courses.get(id); // Obtiene el curso con el ID especificado
  }

  // Método para actualizar un curso
  Future<void> updateCourse(Course course) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.courses.put(course);
    });
  }

  // Método para eliminar un curso
  Future<void> deleteCourse(int id) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.courses.delete(id);
    });
  }

  // CRUD for Signatures
  Future<void> addSignature(Signature signature) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.signatures.put(signature);
    });
    print('Asignatura guardada: Name: ${signature.name}, Id: ${signature.id}, Date: ${signature.date}, IdCourse: ${signature.courseId}');
  }

  Future<List<Signature>> getSignaturesByCourseId(int courseId) async {
    final isar = await _openDB();
    return await isar.signatures
        .filter()
        .courseIdEqualTo(courseId)
        .findAll();
  }

  Future<void> updateSignature(Signature signature) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.signatures.put(signature);
    });
  }

  Future<void> deleteSignature(int id) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.signatures.delete(id);
    });
  }


  // CRUD for Content
  Future<void> addContent(Content content) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.contents.put(content);
    });
  }

  Future<List<Content>> getContents() async {
    final isar = await _openDB();
    return await isar.contents.where().findAll();
  }

  Future<void> updateContent(Content content) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.contents.put(content);
    });
  }

  Future<void> deleteContent(int id) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.contents.delete(id);
    });
  }

  // CRUD for Block
  Future<void> addBlock(Block block) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.blocks.put(block);
    });
  }

  Future<List<Block>> getBlocks() async {
    final isar = await _openDB();
    return await isar.blocks.where().findAll();
  }

  Future<void> updateBlock(Block block) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.blocks.put(block);
    });
  }

  Future<void> deleteBlock(int id) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.blocks.delete(id);
    });
  }
}
