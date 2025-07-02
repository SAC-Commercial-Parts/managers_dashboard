import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFDC2626);
  static const Color darkRed = Color(0xFFB91C1C);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF374151);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.red,
      primaryColor: primaryRed,
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
      ),
      cardTheme: CardThemeData(
        color: white,
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
      drawerTheme: const DrawerThemeData(
        backgroundColor: white,
      ),
    );
  }
}