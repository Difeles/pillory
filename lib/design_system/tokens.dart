import 'package:flutter/material.dart';

/// Pillory design tokens. Components take values from here, not literals.
abstract final class AppColors {
  static const primary = Color(0xFF7446D0);
  static const primaryDeep = Color(0xFF5B33B0);
  static const tint = Color(0xFFEFE8FC);
  static const background = Color(0xFFF7F5FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF211D29);
  static const textSecondary = Color(0xFF625C6E);
  static const inputBorder = Color(0xFF8A8499);
  static const divider = Color(0xFFE6E1EE);
  static const success = Color(0xFF23775C);
  static const warning = Color(0xFF915C0E);
  static const danger = Color(0xFFB83A46);
  static const dangerTint = Color(0xFFFBE6E8);
  // Each status colour keeps ≥4.5:1 on its own tint.
  static const successTint = Color(0xFFE3F3EC);
  static const warningTint = Color(0xFFFBF0DC);

  // Pastels fail text contrast on white: fills and decoration only.
  static const pink = Color(0xFFF3A3C5);
  static const blue = Color(0xFF91AEE8);
  static const mint = Color(0xFF70D2C7);
  static const orange = Color(0xFFFFAD62);
}

/// A 4-point scale.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const ms = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppRadii {
  /// Fields, chips, menus, snack bars.
  static const sm = 12.0;

  /// Cards.
  static const md = 20.0;

  /// Dialogs and large blocks.
  static const lg = 28.0;
}

abstract final class AppSizes {
  static const illustration = 96.0;
  static const illustrationIcon = 48.0;
  static const badgeIcon = 16.0;

  /// The tinted square that shows a medicine's form.
  static const avatar = 48.0;
  static const avatarIcon = 24.0;
}

abstract final class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x147446D0), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const raised = [
    BoxShadow(color: Color(0x1F7446D0), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const curve = Curves.easeOutCubic;
}

/// Type roles. Sizes are logical: the system text scale still applies.
abstract final class AppType {
  static const family = 'Onest';

  static const display = TextStyle(
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  static const title = TextStyle(
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );
  static const cardTitle = TextStyle(
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static const body = TextStyle(
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static const caption = TextStyle(
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );
  static const numeric = TextStyle(
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const label = TextStyle(
    fontSize: 14,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
}

/// Smallest comfortable touch target.
const kMinTapSize = 48.0;
