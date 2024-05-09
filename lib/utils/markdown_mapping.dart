import 'package:flutter/material.dart';

final markdownMap = {
  //For mentions
  r"@.\w+": const TextStyle(
    color: Colors.amber,
  ),
  //italic text
  r'_(.*?)\_': const TextStyle(
    fontStyle: FontStyle.italic,
  ),
  //strikethrough text
  '~(.*?)~': const TextStyle(
    decoration: TextDecoration.lineThrough,
  ),
  //bold text
  r'\*(.*?)\*': const TextStyle(
    fontWeight: FontWeight.bold,
  ),
  //code block
  r'```(.*?)```': const TextStyle(
    fontSize: 16,
    backgroundColor: Color(0xFFE0E0E0),
    fontFamily: "monospace",
  ),
};
