import 'package:flutter/material.dart';
import 'package:groq_some_notes/models/notes.dart';
import 'package:groq_some_notes/models/tasks.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class GroqTasksDatabase extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([NotesSchema, TasksSchema], directory: dir.path);
  }

  final List<Notes> currentNotes = [];
  final List<Tasks> currentTasks = [];

  Future<void> addNote(String title, String body) async {
    final newNote = Notes()
      ..title = title
      ..bodty = body
      ..createdAt = DateTime.now();

    await isar.writeTxn(() => isar.notes.put(newNote));
    fetchNotes();
  }

  Future<void> addTask(String tasks) async {
    final newTask = Tasks()
      ..taskList = tasks
      ..createdAt = DateTime.now();

    await isar.writeTxn(() => isar.tasks.put(newTask));
    fetchTasks();
  }

  Future<void> fetchNotes() async {
    List<Notes> fetchedNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    List<Tasks> fetchedTasks = await isar.tasks.where().findAll();
    currentTasks.clear();
    currentTasks.addAll(fetchedTasks);
    notifyListeners();
  }

  Future<void> updateNote(int id, String newTitle, String newBody) async {
    final existingNote = await isar.notes.get(id);
    if (existingNote != null) {
      existingNote.title = newTitle;
      existingNote.bodty = newBody;

      await isar.writeTxn(() => isar.notes.put(existingNote));
      await fetchNotes();
    }
  }

  Future<void> updateTasks(int id, String? newTask, bool isDone) async {
    final existingTask = await isar.tasks.get(id);
    if (existingTask != null) {
      if (newTask != null){
        existingTask.taskList = newTask;
      }
      existingTask.isDone = isDone;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
      await fetchTasks();
    }
  }

  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }

  Future<void> deleteTask(int id) async {
    await isar.writeTxn(() => isar.tasks.delete(id));
    await fetchTasks();
  }
}
