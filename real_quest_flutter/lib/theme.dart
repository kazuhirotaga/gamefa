import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF4A90E2);
  static const secondaryColor = Color(0xFF357ABD);
  static const accentColor = Color(0xFFFFB800);
  static const errorColor = Color(0xFFFF6B6B);
  static const successColor = Color(0xFF52C41A);
  
  // static final TextTheme _textTheme = GoogleFonts.notoSansJpTextTheme();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
    ),
    // textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    // cardTheme: CardTheme(
    //   elevation: 4,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    // ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
    ),
    // textTheme: _textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    // cardTheme: CardTheme(
    //   elevation: 4,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    // ),
  );
}
