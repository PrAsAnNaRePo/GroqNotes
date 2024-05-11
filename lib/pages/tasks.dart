import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groq_some_notes/components/task_card.dart';
import 'package:groq_some_notes/database/groq_tasks.dart';
import 'package:groq_some_notes/models/tasks.dart';
import 'package:groq_some_notes/pages/notes.dart';
import 'package:groq_some_notes/utils/get_tasks_list.dart';
import 'package:groq_some_notes/utils/voice_to_text.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record_mp3/record_mp3.dart';
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
  bool startRec = false;
  String audioPath = "";
  bool makeShrimmer = false;

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

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = "${storageDirectory.path}/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return "$sdPath/audio_task.mp3";
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      audioPath = await getFilePath();
      RecordMp3.instance.start(audioPath, (type) {
        setState(() {});
      });
    } else {}
    setState(() {});
  }

  void stopRecord() {
    bool s = RecordMp3.instance.stop();
    if (s) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskDatabase = context.watch<GroqTasksDatabase>();
    List<Tasks> currentTasks = taskDatabase.currentTasks;

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
          size: 36,
          color: Theme.of(context).colorScheme.secondary,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                startRec = !startRec;
                startRecord();
              });
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Image(
                image: AssetImage("assets/images/ai_mic.gif"),
                width: 38,
                height: 38,
                color: Colors.amber,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const NotesPage();
                  },
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 11,
              ),
              child: Image.asset(
                'assets/images/writing.png',
                height: 26,
                width: 26,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
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
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.background,
                        width: 2),
                  ),
                  elevation: 10,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ])),
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
                            HapticFeedback.mediumImpact();
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
                                color: Theme.of(context).colorScheme.primary,
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
        child: Column(
          children: [
            const SizedBox(height: 30),
            Visibility(
              visible: startRec,
              child: Column(
                children: [
                  Lottie.asset('assets/lottie/Animation - 1715235771226.json'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          stopRecord();
                          setState(() {
                            makeShrimmer = true;
                          });
                          voiceToText(audioPath).then((value) {
                            if (value.isNotEmpty) {
                              getTasksList(value).then((value) {
                                final tasks = value.split('\n');
                                for (var task in tasks) {
                                  context
                                      .read<GroqTasksDatabase>()
                                      .addTask(task);
                                }
                                setState(() {
                                  makeShrimmer = false;
                                });
                              });
                            }
                          });
                          setState(() {
                            startRec = !startRec;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            "Stop",
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).colorScheme.background,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          stopRecord();
                          setState(() {
                            startRec = !startRec;
                          });
                        },
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Image(
                              image:
                                  const AssetImage('assets/images/close.png'),
                              width: 32,
                              height: 32,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            Expanded(
              child: currentTasks.isEmpty
                  ? Center(
                      child: Text(
                        "No notes available",
                        style: GoogleFonts.openSans(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    )
                  : makeShrimmer
                      ? currentTasks.isEmpty
                          ? CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.secondary,
                            )
                          : Shimmer.fromColors(
                              baseColor: Colors.grey.shade600,
                              highlightColor: Colors.grey.shade800,
                              direction: ShimmerDirection.ltr,
                              child: ListView.builder(
                                itemCount: currentTasks.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TaskCard(task: currentTasks[index]),
                                    ],
                                  );
                                },
                              ),
                            )
                      : ListView.builder(
                          itemCount: currentTasks.length,
                          itemBuilder: (context, index) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      manualTaskController.text =
                                          currentTasks[index].taskList;
                                      showGeneralDialog(
                                        context: context,
                                        pageBuilder: (context, animation,
                                            secondaryAnimation) {
                                          return ScaleTransition(
                                            scale: CurvedAnimation(
                                              parent: animation,
                                              curve: Curves
                                                  .elasticInOut, // This curve provides a spring-like effect
                                              reverseCurve: Curves.easeOutCubic,
                                            ),
                                            child: Dialog(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.2),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                side: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .background,
                                                    width: 2),
                                              ),
                                              elevation: 10,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Colors.white
                                                              .withOpacity(0.2),
                                                          Colors.white
                                                              .withOpacity(0.1),
                                                        ])),
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize
                                                      .min, // To keep the dialog compact
                                                  children: [
                                                    TextField(
                                                      cursorColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary,
                                                      autofocus: true,
                                                      maxLines: 1,
                                                      controller:
                                                          manualTaskController,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            "Enter your task here...",
                                                        hintStyle:
                                                            const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary),
                                                        ),
                                                        filled: true,
                                                        fillColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .surface,
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 20,
                                                                vertical: 10),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height:
                                                            20), // Space between text field and button
                                                    InkWell(
                                                      onTap: () {
                                                        HapticFeedback
                                                            .mediumImpact();
                                                        if (manualTaskController
                                                            .text.isNotEmpty) {
                                                          context
                                                              .read<
                                                                  GroqTasksDatabase>()
                                                              .updateTasks(
                                                                  currentTasks[
                                                                          index]
                                                                      .id,
                                                                  manualTaskController
                                                                      .text,
                                                                  currentTasks[
                                                                          index]
                                                                      .isDone);
                                                          manualTaskController
                                                              .clear();
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      },
                                                      child: Ink(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.1),
                                                              spreadRadius: 1,
                                                              blurRadius: 10,
                                                              offset:
                                                                  const Offset(
                                                                      0, 3),
                                                            ),
                                                          ],
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Text(
                                                          "Save",
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                            const Duration(milliseconds: 500),
                                        barrierDismissible: true,
                                        barrierLabel: 'Dismiss',
                                      );
                                    },
                                    child: TaskCard(task: currentTasks[index])),
                              ],
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}
