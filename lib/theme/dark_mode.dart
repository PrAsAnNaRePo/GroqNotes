import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
      background: Colors.black,
      primary: Colors.grey.shade900,
      secondary: const Color.fromARGB(255, 214, 159, 8),
      inversePrimary: Colors.white),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Color.fromARGB(255, 214, 159, 8),
    selectionColor: Color.fromARGB(255, 214, 159, 8).withOpacity(0.5),
    selectionHandleColor: Color.fromARGB(255, 214, 159, 8),
  ),
);
