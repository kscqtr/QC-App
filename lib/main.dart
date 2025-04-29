import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'pages/selection_page.dart'; // Import the SelectionPage from the 'pages' folder

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Use Google Fonts for a more modern look (if available, otherwise, leave default)
        fontFamily: GoogleFonts.inter().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w600), //semi-bold
          iconTheme: IconThemeData(color: Colors.red),
        ),
        scaffoldBackgroundColor: Colors.grey[50], // Lighter background (almost white)
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.black54, fontSize: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered)) {
                  return Colors.red.shade700;
                }
                return Colors.red;
              },
            ),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            textStyle: WidgetStateProperty.all<TextStyle>(
              TextStyle(fontFamily: GoogleFonts.inter().fontFamily, fontWeight: FontWeight.w500, fontSize: 18), //medium
            ),
            shape: WidgetStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            elevation: WidgetStateProperty.resolveWith<double>((states) {
              if (states.contains(WidgetState.pressed)) {
                return 2;
              }
              return 5;
            }),
            shadowColor: WidgetStateProperty.all<Color>(Colors.black.withValues()),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(fontFamily: GoogleFonts.inter().fontFamily, color: Colors.black54),
          hintStyle: TextStyle(fontFamily: GoogleFonts.inter().fontFamily, color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey, width: 0.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      home: const SelectionPage(),
    );
  }
}
