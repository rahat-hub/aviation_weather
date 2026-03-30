import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color bg = Color(0xFF0A0E1A);
  static const Color bgCard = Color(0xFF111827);
  static const Color bgCardLight = Color(0xFF1A2235);
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);
  static const Color border = Color(0xFF1E293B);
  static const Color borderLight = Color(0xFF2D3748);
  static const Color radarBlue = Color(0xFF0EA5E9);
  static const Color windCyan = Color(0xFF22D3EE);
  static const Color tempOrange = Color(0xFFF97316);
  static const Color humidYellow = Color(0xFFEAB308);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentGold,
          surface: bgCard,
        ),
        textTheme: GoogleFonts.jetBrainsMonoTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.spaceGrotesk(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: GoogleFonts.jetBrainsMono(
            color: textSecondary,
            fontSize: 12,
          ),
        ),
      );
}
