import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    // 1. Color Scheme
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(
      0xFFF7F7F8,
    ), // A slightly warmer, modern off-white
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3B82F6), // A modern, slightly muted blue
      background: const Color(0xFFF7F7F8),
      surface: Colors.white,
      primary: const Color(0xFF3B82F6),
      onSurface: const Color(0xFF1F2937), // A dark slate for text
    ),

    // 2. Typography
    fontFamily: 'Inter', // Make sure to add this font to your project
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
      bodyMedium: TextStyle(color: Color(0xFF4B5563)),
      bodySmall: TextStyle(color: Color(0xFF6B7280)),
    ),

    // 3. Component Themes
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF7F7F8),
      elevation: 0,
      scrolledUnderElevation: 0.5, // Subtle shadow when scrolling
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1F2937)),
      titleTextStyle: TextStyle(
        color: Color(0xFF111827),
        fontWeight: FontWeight.bold,
        fontSize: 18,
        fontFamily: 'Inter',
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0, // Use borders instead of shadows for a flatter look
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey[200]!),
      ),
    ),

    // NEW: Theme for ExpansionTiles used in Farm Management
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: const Color(0xFF3B82F6),
      collapsedIconColor: Colors.grey[600],
      shape: const Border(), // Remove the default borders
      collapsedShape: const Border(),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          fontSize: 16,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
    ),

    listTileTheme: ListTileThemeData(iconColor: Colors.grey[600]),
  );
}
