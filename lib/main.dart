import 'package:flutter/material.dart';

import 'home_page.dart';

void main() {
  runApp(const MovieLibraryApp());
}

/// Root widget: sets up the Material 3 dark cinematic theme.
class MovieLibraryApp extends StatelessWidget {
  const MovieLibraryApp({super.key});

  /// Professional gold accent used across the app.
  static const Color accentColor = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary: accentColor,
      surface: const Color(0xFF0E0F14), // scaffold / app bar background
      surfaceContainerHigh: const Color(0xFF1B1D26), // card background
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
    );

    final ThemeData theme = base.copyWith(
      textTheme: base.textTheme.copyWith(
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: accentColor),
        actionsIconTheme: const IconThemeData(color: accentColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIconColor: accentColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );

    return MaterialApp(
      title: 'Movie Library',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const HomePage(),
    );
  }
}
