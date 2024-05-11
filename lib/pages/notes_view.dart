import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groq_some_notes/database/groq_tasks.dart';
import 'package:groq_some_notes/models/notes.dart';
import 'package:groq_some_notes/utils/convert_int_mon_to_string.dart';
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
  final markdownController = ScrollController();
  bool isEditing = false;

  @override
  void initState() {
    titleController.text = widget.note.title.isEmpty ? "" : widget.note.title;
    bodyController.text = widget.note.bodty.isEmpty ? "" : widget.note.bodty;
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
          GestureDetector(
            onTap: () {
              context.read<GroqTasksDatabase>().deleteNote(widget.note.id);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Image.asset(
                "assets/images/delete.png",
                width: 26,
                height: 26,
                color: Colors.redAccent,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
            child: isEditing
                ? Container(
                    margin: EdgeInsets.only(right: 20, left: 10),
                    child: Image.asset(
                      'assets/images/eye.png',
                      width: 26,
                      height: 26,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(right: 20, left: 10),
                    child: Image.asset(
                      'assets/images/write.png',
                      width: 26,
                      height: 26,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
          ),
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
        child: isEditing
            ? Column(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8, left: 8, right: 8),
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
                                "${widget.note.createdAt!.day} ${monthNames[widget.note.createdAt!.month]}  ${widget.note.createdAt!.hour}:${widget.note.createdAt!.minute}",
                                style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
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
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : SelectionArea(
                child: Markdown(
                  controller: markdownController,
                  data: "# ${titleController.text}\n${bodyController.text}",
                  styleSheet: MarkdownStyleSheet(
                    h1: GoogleFonts.raleway(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                    h2: GoogleFonts.raleway(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    p: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                    a: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                      decoration: TextDecoration.underline,
                      decorationThickness: 2,
                    ),
                    blockquote: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.italic,
                      backgroundColor: Colors.grey[200],
                    ),
                    code: GoogleFonts.sourceCodePro(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
