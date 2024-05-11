import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
      background: Colors.grey.shade300,
      primary: Colors.grey.shade400,
      secondary: Colors.deepPurple,
      inversePrimary: Colors.black),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.deepPurple,
    selectionColor: Colors.deepPurple.withOpacity(0.5),
    selectionHandleColor: Colors.deepPurple,
  ),
);
