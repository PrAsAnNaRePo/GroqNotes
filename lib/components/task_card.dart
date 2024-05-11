import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groq_some_notes/database/groq_tasks.dart';
import 'package:groq_some_notes/models/tasks.dart';
import 'package:groq_some_notes/utils/convert_int_mon_to_string.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatefulWidget {
  final Tasks task;
  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              borderRadius: BorderRadius.circular(35),
              onPressed: (context) {
                context.read<GroqTasksDatabase>().deleteTask(widget.task.id);
                context.read<GroqTasksDatabase>().fetchTasks();
              },
              icon: Icons.delete,
              backgroundColor: Colors.red,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .inversePrimary
                      .withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]),
          width: MediaQuery.of(context).size.width * 0.9,
          child: ListTile(
            leading: Checkbox(
              activeColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              // checkColor: Theme.of(context).colorScheme.secondary,
              value: widget.task.isDone,
              onChanged: (value) {
                context
                    .read<GroqTasksDatabase>()
                    .updateTasks(widget.task.id, null, !widget.task.isDone);
              },
            ),
            title: Text(
              widget.task.taskList.length > 35
                  ? "${widget.task.taskList.substring(0, 35)}..."
                  : widget.task.taskList,
              style: widget.task.isDone
                  ? GoogleFonts.poppins(
                      color: Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withOpacity(0.7),
                      decoration: TextDecoration.lineThrough,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      decorationThickness: 2.5,
                      decorationColor: Theme.of(context).colorScheme.secondary,
                    )
                  : GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
            ),
            subtitle: Text(
              "${widget.task.createdAt!.day} ${monthNames[widget.task.createdAt!.month]}",
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300),
            ),
          ),
        ),
      ),
    );
  }
}
