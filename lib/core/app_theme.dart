import 'package:flutter/material.dart';

////////////////////////////////////////////////////////////////////////////
//                                APP THEME                              //
////////////////////////////////////////////////////////////////////////////
class AppTheme {
  // Common Colors (can be used by both themes or adjusted for dark)
  static const Color primaryRed = Color(0xFFDC2626);
  static const Color darkRed = Color(0xFFB91C1C);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Light Theme Specific Colors
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF374151);

  // Dark Theme Specific Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1D1616);
  static const Color lightText = Color(0xFFE0E0E0);
  static const Color mediumGray = Color(0xFFBBBBBB);

  ////////////////////////////////////////////////////////////////////////////
  //                              LIGHT THEME                               //
  ////////////////////////////////////////////////////////////////////////////
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light, // Explicitly declare brightness
      primarySwatch: Colors.red,
      primaryColor: primaryRed,
      canvasColor: lightGray, // Used by Drawer, etc.
      scaffoldBackgroundColor: lightGray,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: white), // Ensure icons are visible
      ),
      cardTheme: CardThemeData(
        color: white, // Cards are white in light mode
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      // Text theme for general text colors in light mode
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkGray),
        bodyMedium: TextStyle(color: darkGray),
        // Add more text styles as needed
      ),
      iconTheme: const IconThemeData(color: darkGray), // Default icon color for light theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: white,
      ),
      // Input field decoration theme
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: darkGray),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                               DARK THEME                               //
  ////////////////////////////////////////////////////////////////////////////
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark, // Explicitly declare brightness
      primarySwatch: Colors.red,
      primaryColor: primaryRed, // Primary accent color can remain the same
      canvasColor: darkBackground, // Used by Drawer, etc.
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: white), // Ensure icons are visible
      ),
      cardTheme: CardThemeData(
        color: darkSurface, // Cards are dark in dark mode
        elevation: 4, // Slightly higher elevation for contrast
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed, // Red button remains prominent
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      // Text theme for general text colors in dark mode
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: lightText),
        bodyMedium: TextStyle(color: lightText),
        // Add more text styles as needed
      ),
      iconTheme: const IconThemeData(color: lightText), // Default icon color for dark theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkSurface, // Darker drawer background
      ),
      // Input field decoration theme for dark mode
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: mediumGray),
        hintStyle: const TextStyle(color: Color(0xFF616161)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
      ),
    );
  }
}