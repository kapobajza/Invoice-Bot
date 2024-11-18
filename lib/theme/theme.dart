import 'package:flutter/material.dart';
import 'package:invoice_bot/theme/spacing.dart';

const _primaryColor = Color(0xFFB5E3E9);

final ThemeData invoiceBotTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primaryColor,
  ),
  extensions: [
    AppSpacing(
      xp5: 2,
      x1: 4,
      x1p5: 6,
      x2: 8,
      x2p5: 10,
      x3: 12,
      x3p5: 14,
      x4: 16,
      x4p5: 18,
      x5: 20,
      x5p5: 22,
      x6: 24,
      x6p5: 26,
      x7: 28,
      x7p5: 30,
      x8: 32,
      x8p5: 34,
      x9: 36,
      x9p5: 38,
      x10: 40,
    ),
  ],
);
