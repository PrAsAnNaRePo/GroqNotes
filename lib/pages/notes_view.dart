import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groq_some_notes/database/groq_tasks.dart';
import 'package:groq_some_notes/models/notes.dart';
import 'package:provider/provider.dart';

class NotesView extends StatefulWidget {
  final Notes note;

  const NotesView({super.key, required this.note});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  void initState() {
    titleController.text = widget.note.title;
    bodyController.text = widget.note.bodty;
    titleController.addListener(_update);
    bodyController.addListener(_update);
    super.initState();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          Visibility(
            visible: titleController.text != widget.note.title ||
                bodyController.text != widget.note.bodty,
            child: IconButton(
              onPressed: () {
                context.read<GroqTasksDatabase>().updateNote(
                    widget.note.id, titleController.text, bodyController.text);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: TextField(
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
                          "${DateTime.now().day}/${DateTime.now().month}  ${DateTime.now().hour}:${DateTime.now().minute}",
                          style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
