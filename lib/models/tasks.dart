import 'package:isar/isar.dart';

part 'tasks.g.dart';

@Collection()
class Tasks {
  Id id = Isar.autoIncrement;
  DateTime? createdAt;
  late String taskList;
}
