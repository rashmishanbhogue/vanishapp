// app_constants.dart

import 'package:flutter/material.dart';

import '../models/paper_theme.dart';

class AppConstants {
  static const List<PaperTheme> paperThemes = [
    PaperTheme(
      name: 'yellow',
      colour: Color(0xFFFEF9C3),
      dotColour: Color(0xFFFEF08A),
    ),
    PaperTheme(
      name: 'pink',
      colour: Color(0xFFFCE7F3),
      dotColour: Color(0xFFFBCFE8),
    ),
    PaperTheme(
      name: 'green',
      colour: Color(0xFFDCFCE7),
      dotColour: Color(0xFFBBF7D0),
    ),
    PaperTheme(
      name: 'blue',
      colour: Color(0xFFDBEAFE),
      dotColour: Color(0xFFBFDBFE),
    ),
    PaperTheme(
      name: 'cream',
      colour: Color(0xFFFAF8F5),
      dotColour: Color(0xFFE8E0D0),
    ),
  ];

  static const List<String> vanishPhrases = [
    'let it go',
    'throw it away',
    'burn it',
    'gone.',
  ];

  static const Color appBackground = Color(0xFFFAF8F5);
  static const Color paperText = Color(0xB8000000);
  static const Color paperHint = Color(0x38000000);
  static const Color mutedText = Color(0x4D000000);

  static const double paperMaxWidth = 360;
  static const double paperMaxHeight = 480;
}
