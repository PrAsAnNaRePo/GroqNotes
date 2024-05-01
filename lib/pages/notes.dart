import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groq_some_notes/components/notes_card.dart';
import 'package:groq_some_notes/database/groq_tasks.dart';
import 'package:groq_some_notes/models/notes.dart';
import 'package:groq_some_notes/pages/create_note.dart';
import 'package:groq_some_notes/pages/notes_view.dart';
import 'package:groq_some_notes/pages/tasks.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  void initState() {
    super.initState();
    context.read<GroqTasksDatabase>().fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    final noteDatabase = context.watch<GroqTasksDatabase>();
    List<Notes> currentNotes = noteDatabase.currentNotes;
    currentNotes.sort((a, b) {
      var aCreatedAt = a.createdAt ?? DateTime(0);
      var bCreatedAt = b.createdAt ?? DateTime(0);

      return bCreatedAt.compareTo(aCreatedAt);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          "Notes",
          style: GoogleFonts.openSans(
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        leading: Icon(
          Icons.note_alt_outlined,
          size: 28,
          color: Theme.of(context).colorScheme.secondary,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const TaskPage();
                  },
                ),
              );
            },
            icon: const Icon(
              Icons.task_alt,
              size: 28,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: currentNotes.isNotEmpty
                    ? MasonryGridView.builder(
                        itemCount: currentNotes.length,
                        gridDelegate:
                            const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                        itemBuilder: (context, index) {
                          return Builder(builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotesView(
                                      note: currentNotes[index],
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () {
                                showPopover(
                                  width: 80,
                                  height: 60,
                                  radius: 20,
                                  arrowHeight: 20,
                                  arrowWidth: 30,
                                  backgroundColor:
                                      Colors.red.shade500.withOpacity(0.4),
                                  context: context,
                                  bodyBuilder: (context) {
                                    return GestureDetector(
                                      onTap: () {
                                        context
                                            .read<GroqTasksDatabase>()
                                            .deleteNote(currentNotes[index].id);
                                        Navigator.pop(context);
                                      },
                                      child: Center(
                                        child: Text(
                                          "delete",
                                          style:
                                              GoogleFonts.poppins(fontSize: 18),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: NotesCard(
                                title: currentNotes[index].title,
                                body: currentNotes[index].bodty,
                                date: currentNotes[index].createdAt,
                              ),
                            );
                          });
                        },
                      )
                    : Center(
                        child: Text(
                          "No notes available",
                          style: GoogleFonts.openSans(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateNotes(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.secondary,
          size: 35,
        ),
      ),
    );
  }
}
