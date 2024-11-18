import 'package:isar/isar.dart';
import 'package:flutter_application_1/models/signature.dart';


part 'course.g.dart';

@collection
class Course {
  Id id = Isar.autoIncrement;

  late String titulo;
  late String professor;
  String? description;

  final classes = IsarLinks<Signature>(); // Relación con la colección Class
}


