import 'package:flutter/material.dart';

class AppSpacing extends ThemeExtension<AppSpacing> {
  /// x05 = 2
  final double xp5;

  /// x1 = 4
  final double x1;

  /// x1p5 = 6
  final double x1p5;

  /// x2 = 8
  final double x2;

  /// x2p5 = 10
  final double x2p5;

  /// x3 = 12
  final double x3;

  /// x3p5 = 14
  final double x3p5;

  /// x4 = 16
  final double x4;

  /// x4p5 = 18
  final double x4p5;

  /// x5 = 20
  final double x5;

  /// x5p5 = 22
  final double x5p5;

  /// x6 = 24
  final double x6;

  /// x6p5 = 26
  final double x6p5;

  /// x7 = 28
  final double x7;

  /// x7p5 = 30
  final double x7p5;

  /// x8 = 32
  final double x8;

  /// x8p5 = 34
  final double x8p5;

  /// x9 = 36
  final double x9;

  /// x9p5 = 38
  final double x9p5;

  /// x10 = 40
  final double x10;

  AppSpacing({
    required this.xp5,
    required this.x1,
    required this.x1p5,
    required this.x2,
    required this.x2p5,
    required this.x3,
    required this.x3p5,
    required this.x4,
    required this.x4p5,
    required this.x5,
    required this.x5p5,
    required this.x6,
    required this.x6p5,
    required this.x7,
    required this.x7p5,
    required this.x8,
    required this.x8p5,
    required this.x9,
    required this.x9p5,
    required this.x10,
  });

  @override
  ThemeExtension<AppSpacing> copyWith({
    double? xp5,
    double? x1,
    double? x1p5,
    double? x2,
    double? x2p5,
    double? x3,
    double? x3p5,
    double? x4,
    double? x4p5,
    double? x5,
    double? x5p5,
    double? x6,
    double? x6p5,
    double? x7,
    double? x7p5,
    double? x8,
    double? x8p5,
    double? x9,
    double? x9p5,
    double? x10,
  }) {
    return AppSpacing(
      xp5: xp5 ?? this.xp5,
      x1: x1 ?? this.x1,
      x1p5: x1p5 ?? this.x1p5,
      x2: x2 ?? this.x2,
      x2p5: x2p5 ?? this.x2p5,
      x3: x3 ?? this.x3,
      x3p5: x3p5 ?? this.x3p5,
      x4: x4 ?? this.x4,
      x4p5: x4p5 ?? this.x4p5,
      x5: x5 ?? this.x5,
      x5p5: x5p5 ?? this.x5p5,
      x6: x6 ?? this.x6,
      x6p5: x6p5 ?? this.x6p5,
      x7: x7 ?? this.x7,
      x7p5: x7p5 ?? this.x7p5,
      x8: x8 ?? this.x8,
      x8p5: x8p5 ?? this.x8p5,
      x9: x9 ?? this.x9,
      x9p5: x9p5 ?? this.x9p5,
      x10: x10 ?? this.x10,
    );
  }

  @override
  ThemeExtension<AppSpacing> lerp(
    covariant ThemeExtension<AppSpacing>? other,
    double t,
  ) {
    if (other is! AppSpacing) {
      return this;
    }

    return lerp(other, t);
  }
}
