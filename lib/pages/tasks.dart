import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groq_some_notes/components/task_card.dart';
import 'package:groq_some_notes/database/groq_tasks.dart';
import 'package:groq_some_notes/models/tasks.dart';
import 'package:groq_some_notes/pages/notes.dart';
import 'package:groq_some_notes/utils/get_tasks_list.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController aiTaskController = TextEditingController();
  final TextEditingController manualTaskController = TextEditingController();
  Future<String>? _futureResponse;
  bool _isTaskAdded = false;

  @override
  void initState() {
    context.read<GroqTasksDatabase>().fetchTasks();
    super.initState();
  }

  @override
  void dispose() {
    aiTaskController.dispose();
    manualTaskController.dispose();
    super.dispose();
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Network error! Please try again later.'),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskDatabase = context.watch<GroqTasksDatabase>();
    List<Tasks> currentTasks = taskDatabase.currentTasks;
    currentTasks.sort((a, b) {
      var aCreatedAt = a.createdAt ?? DateTime(0);
      var bCreatedAt = b.createdAt ?? DateTime(0);

      return bCreatedAt.compareTo(aCreatedAt);
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          "Tasks",
          style: GoogleFonts.openSans(fontSize: 25),
        ),
        centerTitle: true,
        leading: Icon(
          Icons.task_alt,
          size: 28,
          color: Theme.of(context).colorScheme.secondary,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotesPage()),
              );
            },
            icon: const Icon(Icons.note_alt_outlined, size: 28),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        onPressed: () {
          showGeneralDialog(
            context: context,
            pageBuilder: (context, animation, secondaryAnimation) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves
                      .elasticInOut, // This curve provides a spring-like effect
                  reverseCurve: Curves.easeOutCubic,
                ),
                child: Dialog(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.background,
                        width: 2),
                  ),
                  elevation: 10,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // To keep the dialog compact
                      children: [
                        TextField(
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          autofocus: true,
                          maxLines: 1,
                          controller: manualTaskController,
                          decoration: InputDecoration(
                            hintText: "Enter your task here...",
                            hintStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                        const SizedBox(
                            height: 20), // Space between text field and button
                        InkWell(
                          onTap: () {
                            if (manualTaskController.text.isNotEmpty) {
                              context
                                  .read<GroqTasksDatabase>()
                                  .addTask(manualTaskController.text);
                              manualTaskController.clear();
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            }
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              "Create",
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            transitionDuration:
                const Duration(milliseconds: 500), // Duration of the transition
            barrierDismissible: true,
            barrierLabel: 'Dismiss',
          );
        },
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.secondary,
          size: 35,
        ),
      ),
      body: SafeArea(
        // Ensure the body is within the safe area of the screen
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    // This will constrain the width of the TextFormField
                    child: TextFormField(
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      style: GoogleFonts.openSans(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: "Describe your task to me...",
                        hintStyle: GoogleFonts.openSans(fontSize: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                      maxLines: 2,
                      controller: aiTaskController,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (aiTaskController.text.isNotEmpty) {
                        setState(() {
                          FocusScope.of(context).unfocus();
                          _futureResponse = getTasksList(
                              "Create a task list for:\n${aiTaskController.text}");
                        });
                        aiTaskController.clear();
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
                // Takes the remaining space in the column
                child: FutureBuilder(
              future: _futureResponse,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (currentTasks.isNotEmpty) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade700,
                      highlightColor: Colors.grey.shade400,
                      child: Center(
                        child: ListView.builder(
                          itemCount: currentTasks.length,
                          itemBuilder: (context, index) {
                            return TaskCard(
                              task: currentTasks[index],
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  }
                } else if (snapshot.hasData && !_isTaskAdded) {
                  _isTaskAdded = true; // Set flag to true to avoid re-adding
                  List<String> tasks = snapshot.data.toString().split("\n");
                  for (String task in tasks) {
                    context.read<GroqTasksDatabase>().addTask(task);
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      // Clear future to avoid re-triggering addition
                      _futureResponse = null;
                    });
                  });
                } else if (snapshot.hasError) {
                  _showToast(context);
                  return Center(
                    child: Text(
                      "Network error! Please try again later.",
                      style: GoogleFonts.openSans(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  );
                }
                context.read<GroqTasksDatabase>().fetchTasks();
                return currentTasks.isNotEmpty
                    ? Center(
                        child: Center(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(5),
                            itemCount: currentTasks.length,
                            itemBuilder: (context, index) {
                              return TaskCard(
                                task: currentTasks[index],
                              );
                            },
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          "No tasks yet!",
                          style: GoogleFonts.openSans(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      );
              },
            )),
          ],
        ),
      ),
    );
  }
}
