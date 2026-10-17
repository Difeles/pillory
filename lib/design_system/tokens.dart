import 'package:flutter/material.dart';

/// Pillory design tokens. Components take values from here, not literals.
abstract final class AppColors {
  static const primary = Color(0xFF8050D8);
  static const primaryLight = Color(0xFFF0E7FF);
  static const background = Color(0xFFFBF9FE);
  static const surface = Color(0xFFFFFFFF);
  static const pink = Color(0xFFF3A3C5);
  static const blue = Color(0xFF91AEE8);
  static const mint = Color(0xFF70D2C7);
  static const orange = Color(0xFFFFAD62);
  static const textPrimary = Color(0xFF24212B);
  static const textSecondary = Color(0xFF77727F);
  static const success = Color(0xFF31866A);
  static const warning = Color(0xFFB87518);
  static const danger = Color(0xFFC84550);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class AppRadii {
  static const md = 16.0;
  static const lg = 24.0;
}

abstract final class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x148050D8), blurRadius: 16, offset: Offset(0, 4)),
  ];
}

/// Smallest comfortable touch target.
const kMinTapSize = 48.0;
