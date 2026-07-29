import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors defined from the design
  static const Color primaryColor = Color(0xFF31A09F); // Teal
  static const Color secondaryColor = Color(0xFF2D4B7A); // Navy Blue
  static const Color backgroundColor = Color(0xFFFFFFFF); // White
  static const Color darkGray = Color(0xFF333333); // Dark text
  static const Color lightGray = Color(0xFF888888); // Subtitle text
  static const Color unselectedIconColor = Color(0xFFBDBDBD); // Gray for icons

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
      ),
      textTheme: GoogleFonts.montserratTextTheme().copyWith(
        displayLarge: GoogleFonts.montserrat(color: darkGray, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.montserrat(color: darkGray, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.montserrat(color: darkGray, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.montserrat(color: darkGray, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.montserrat(color: darkGray, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.montserrat(color: darkGray, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.montserrat(color: darkGray),
        bodyMedium: GoogleFonts.montserrat(color: darkGray),
        bodySmall: GoogleFonts.montserrat(color: lightGray),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: darkGray),
        titleTextStyle: TextStyle(color: darkGray, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: unselectedIconColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      useMaterial3: true,
    );
  }
}
