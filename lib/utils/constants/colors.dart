import 'package:flutter/material.dart';

class TColors {
  TColors._();

  // Text Colors
  static const Color primary = Color(0xFF0841E2);
  static const Color secondary = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF3A6CF8);
  static const Color lightPrimary = Color(0xFFB5C8FD);
  static const Color veryLightPrimary = Color(0xFFCDDAFD);

  // Background Colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  static const Gradient purpleBlueGradient = LinearGradient(
    colors: [
      Color(0xFFFF33FF),
      Color(0xFF8E2BFF),
      Color(0xFF3B3BFF),
      Color(0xFF2B4FF2),
      Color(0xFF0841E2),
    ],
    stops: [0.0, 0.2, 0.45, 0.7, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Color blueBackground = Color(0xFF1A2B80);

  static const Color light = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFFFFFFF);

  // Background container Colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = TColors.textWhite.withValues(alpha: 0.1);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF0841E2);
  static const Color buttonSecondary = Color(0xFF4B6FEA);
  static const Color buttonDisabled = Color(0xFFB3C2F2);
  static const Color buttonLike = Color(0xFF0566ff);

  // Border Colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and Validation Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color success = Color(0xFF36C450);
  static const Color successContainer = Color(0xFFC6F6D1);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color info = Color(0xFF675496);
  static const Color infoContainer = Color(0xFFC8B3FD);

  // Neutral Shades
  static const Color black = Color(0xFF272727);
  static const Color darkerBlack = Color(0xFF181818);
  static const Color darkerGrey = Color(0xFF677498);
  static const Color darkGrey = Color(0xFF959EB7);
  static const Color lightDarkGrey = Color(0xFFA4ACC1);
  static const Color grey = Color(0xFFC8CDDA);
  static const Color softGrey = Color(0xFFE1E3EA);
  static const Color lightGrey = Color(0xFFEFF1F5);
  static const Color white = Color(0xFFFFFFFF);

  static const Color personalEscortBkg = Color(0xFFF57C00);
  static const Color groupEscortBkg = Color(0xFF3399FF);
  static const Color familyEscortBkg = Color(0xFF00BCD4);
  static const Color personalEscortIcon = Color(0xFFe3a98a);
  static const Color familyEscortIcon = Color(0xFF55948c);
  static const Color groupEscortIcon = Color(0xFF3f71ed);
}
