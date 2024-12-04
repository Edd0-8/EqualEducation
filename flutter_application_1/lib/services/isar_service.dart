import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_1/models/course.dart';
import 'package:flutter_application_1/models/signature.dart';
import 'package:flutter_application_1/models/content.dart';
import 'package:flutter_application_1/models/block.dart';

class IsarService {
  static Isar? _db; // Variable que almacena la instancia de Isar

  // Apertura de Base de Datos y Validación
  Future<Isar> _openDB() async {
    if (_db != null) {
      return _db!;
    }

    final dir = await getApplicationDocumentsDirectory();
    _db = await Isar.open(
      [CourseSchema, SignatureSchema, ContentSchema, BlockSchema],
      directory: dir.path,
    );

    return _db!;
  }

  // ===========================================================
  // CRUD para Courses
  // ===========================================================
  Future<void> addCourse(Course course) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.courses.put(course);
    });
  }

  Future<List<Course>> getCourses() async {
    final isar = await _openDB();
    return await isar.courses.where().findAll();
  }

  Future<Course?> getCourseById(int id) async {
    final isar = await _openDB();
    return await isar.courses.get(id);
  }

  Future<void> updateCourse(Course course) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.courses.put(course);
    });
  }

  Future<void> deleteCourse(int courseId) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.signatures.filter().courseIdEqualTo(courseId).deleteAll();
      await isar.courses.delete(courseId);
    });
  }

  // ===========================================================
  // CRUD para Signatures
  // ===========================================================
  Future<void> addSignature(Signature signature) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.signatures.put(signature);
    });
  }

  Future<List<Signature>> getSignaturesByCourseId(int courseId) async {
    final isar = await _openDB();
    return await isar.signatures.filter().courseIdEqualTo(courseId).findAll();
  }

  Future<void> updateSignature(Signature signature) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      await isar.signatures.put(signature);
    });
  }

  Future<void> deleteSignatureWithContent(int id) async {
    final isar = await _openDB();
    await isar.writeTxn(() async {
      // Obtener el contenido asociado a la signature
      final content =
          await isar.contents.filter().signatureIdEqualTo(id).findFirst();
      if (content != null) {
        // Eliminar todos los blocks relacionados al contenido
        await isar.blocks.filter().contentIdEqualTo(content.id).deleteAll();
        // Eliminar el contenido relacionado
        await isar.contents.delete(content.id);
      }
      // Eliminar la signature
      await isar.signatures.delete(id);
    });
  }

  // ===========================================================
  // CRUD para Content
  // ===========================================================
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

  Future<Content?> getContentBySignatureId(int signatureId) async {
    final isar = await _openDB();
    return await isar.contents
        .filter()
        .signatureIdEqualTo(signatureId)
        .findFirst();
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

  // ===========================================================
  // CRUD para Block
  // ===========================================================
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

  Future<List<Block>> getBlocksByContentId(int contentId) async {
    final isar = await _openDB();
    return await isar.blocks.filter().contentIdEqualTo(contentId).findAll();
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
