import 'package:isar/isar.dart';
// import 'package:flutter_application_1/models/content.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;
  late String descripcion;
  late bool estado;
  late DateTime timestamp;
}
