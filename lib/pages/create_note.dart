import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groq_some_notes/database/groq_tasks.dart';
import 'package:groq_some_notes/utils/convert_int_mon_to_string.dart';
import 'package:groq_some_notes/utils/get_llm_response.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CreateNotes extends StatefulWidget {
  const CreateNotes({super.key});

  @override
  State<CreateNotes> createState() => _CreateNotesState();
}

class _CreateNotesState extends State<CreateNotes>
    with SingleTickerProviderStateMixin {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  Future<String>? _futureResponse;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this, // vsync is set to this for performance reasons
      duration: const Duration(seconds: 2), // Set the duration of the animation
    );
    _animation = Tween<double>(
      begin: 0, // Start rotation angle
      end: 2 * 3.141, // End rotation angle (2 * pi for a full circle)
    ).animate(_animationController);
    _animationController.repeat();
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Create Note"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("What to do with the text?"),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _futureResponse = getResponse(
                                        "Instruction: ${_controller.text}\ncontent: ${bodyController.text}");
                                  });
                                  _controller.clear();
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.send_rounded,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText:
                                "Ask AI to edit the text like 'Fix grammer'",
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * (_futureResponse == null ? 1 : 3),
                  child: Image(
                    image: const AssetImage("assets/images/energy.png"),
                    width: 35,
                    height: 35,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {
              if (titleController.text.isEmpty || bodyController.text.isEmpty) {
                return;
              }
              context
                  .read<GroqTasksDatabase>()
                  .addNote(titleController.text, bodyController.text);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12, right: 8),
              child: TextField(
                cursorColor: Theme.of(context).colorScheme.secondary,
                controller: titleController,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: "Title",
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 20,
                  ),
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(
                    "${DateTime.now().day} ${monthNames[DateTime.now().month]}  ${DateTime.now().hour}:${DateTime.now().minute}",
                    style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: _futureResponse,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (bodyController.text.isEmpty) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                        ),
                        controller: bodyController,
                        decoration: InputDecoration(
                          hintText: "Body",
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),
                        maxLines: null,
                      ),
                    );
                  }
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade700,
                    highlightColor: Colors.grey.shade400,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                bodyController.text,
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text("Error occured while fetching data");
                } else {
                  if (snapshot.data != null) {
                    bodyController.text = snapshot.data.toString();
                  }
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextFormField(
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                      ),
                      controller: bodyController,
                      decoration: InputDecoration(
                        hintText: "Body",
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                        ),
                      ),
                      maxLines: null,
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
