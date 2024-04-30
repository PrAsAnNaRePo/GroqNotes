import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:groq_some_notes/database/groq_tasks.dart';
import 'package:groq_some_notes/pages/notes.dart';
import 'package:groq_some_notes/theme/dark_mode.dart';
import 'package:groq_some_notes/theme/light_mode.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GroqTasksDatabase.initialize();
  await dotenv.load(fileName: ".env");

  runApp(ChangeNotifierProvider(
    create: (context) => GroqTasksDatabase(),
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NotesPage(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
