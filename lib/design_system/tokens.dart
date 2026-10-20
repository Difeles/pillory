import 'package:flutter/material.dart';

/// Pillory design tokens. Components take values from here, not literals.
abstract final class AppColors {
  static const primary = Color(0xFF5848C5);
  static const primaryDeep = Color(0xFF422FAF);
  static const tint = Color(0xFFE4DFFF);
  static const background = Color(0xFFFAF8FF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1B20);
  static const textSecondary = Color(0xFF474553);
  static const inputBorder = Color(0xFF787585);
  static const divider = Color(0xFFE8E7EE);
  static const success = Color(0xFF006953);
  static const warning = Color(0xFF894F38);
  static const danger = Color(0xFFBA1A1A);
  static const dangerTint = Color(0xFFFFDAD6);
  // Each status colour keeps ≥4.5:1 on its own tint.
  static const successTint = Color(0xFFD9F6EC);
  static const warningTint = Color(0xFFFFDBCE);

  // Pastels fail text contrast on white: fills and decoration only.
  static const pink = Color(0xFFF3A3C5);
  static const blue = Color(0xFF91AEE8);
  static const mint = Color(0xFF70D2C7);
  static const orange = Color(0xFFFFAD62);
  static const surfaceLow = Color(0xFFF4F3FA);
  static const surfaceMid = Color(0xFFEEEDF4);
  static const peach = Color(0xFFFEB295);
  static const mintFill = Color(0xFF9AF4D6);
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
  static const sm = 16.0;

  /// Cards.
  static const md = 24.0;

  /// Dialogs and large blocks.
  static const lg = 32.0;
}

abstract final class AppSizes {
  static const illustration = 96.0;
  static const illustrationIcon = 48.0;
  static const badgeIcon = 16.0;

  /// The tinted square that shows a medicine's form.
  static const avatar = 48.0;
  static const avatarIcon = 24.0;

  /// Day timeline: the rail column, its status dots and the time column
  /// (the last scales with the text).
  static const timelineRail = 24.0;
  static const timelineDot = 12.0;
  static const timelineLine = 1.0;
  static const timelineTime = 56.0;
}

abstract final class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x1F5848C5), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const raised = [
    BoxShadow(color: Color(0x405848C5), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const curve = Curves.easeOutCubic;

  static const press = Duration(milliseconds: 90);
  static const release = Duration(milliseconds: 380);
  static const tab = Duration(milliseconds: 420);

  /// Settles quickly, overshoots slightly: the "springy" feel.
  static const spring = Cubic(.34, 1.4, .5, 1);

  /// Settles quickly with no overshoot.
  static const smooth = Cubic(.22, 1, .36, 1);
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
    fontSize: 16,
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
  static const captionStrong = TextStyle(
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w700,
  );

  /// Small caps-style heading over a block ("ПЛАН ДНЯ"); colour at the use.
  static const overline = TextStyle(
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
  );

  /// Tab labels and other tiny captions.
  static const micro = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  /// The digits on the time wheels: light, so a big number does not shout.
  static const wheel = TextStyle(
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w400,
  );
  static const label = TextStyle(
    fontSize: 14,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
}

/// Smallest comfortable touch target.
const kMinTapSize = 48.0;

/// The colours of one appearance. [AppColors] holds the light values as
/// constants; widgets read the current ones with `context.colors`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.primaryDeep,
    required this.tint,
    required this.background,
    required this.surface,
    required this.surfaceLow,
    required this.surfaceMid,
    required this.textPrimary,
    required this.textSecondary,
    required this.inputBorder,
    required this.divider,
    required this.success,
    required this.onSuccess,
    required this.successTint,
    required this.warning,
    required this.warningTint,
    required this.danger,
    required this.onDanger,
    required this.dangerTint,
    required this.glass,
    required this.glassBorder,
    required this.cardShadow,
    required this.raisedShadow,
  });

  /// Fill of primary actions (white text on it).
  final Color primary;
  final Color onPrimary;

  /// The brand colour as text or an icon on the page: [primary] in the light
  /// appearance, a lighter tone in the dark one.
  final Color accent;
  final Color primaryDeep;
  final Color tint;
  final Color background;
  final Color surface;
  final Color surfaceLow;
  final Color surfaceMid;
  final Color textPrimary;
  final Color textSecondary;
  final Color inputBorder;
  final Color divider;
  final Color success;
  final Color onSuccess;
  final Color successTint;
  final Color warning;
  final Color warningTint;
  final Color danger;
  final Color onDanger;
  final Color dangerTint;

  /// The dock's frosted fill and its hairline.
  final Color glass;
  final Color glassBorder;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> raisedShadow;

  static const light = AppPalette(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    accent: AppColors.primary,
    primaryDeep: AppColors.primaryDeep,
    tint: AppColors.tint,
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceLow: AppColors.surfaceLow,
    surfaceMid: AppColors.surfaceMid,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    inputBorder: AppColors.inputBorder,
    divider: AppColors.divider,
    success: AppColors.success,
    onSuccess: Colors.white,
    successTint: AppColors.successTint,
    warning: AppColors.warning,
    warningTint: AppColors.warningTint,
    danger: AppColors.danger,
    onDanger: Colors.white,
    dangerTint: AppColors.dangerTint,
    glass: Color(0x8CFFFFFF),
    glassBorder: Color(0xA6FFFFFF),
    cardShadow: AppShadows.card,
    raisedShadow: AppShadows.raised,
  );

  static const dark = AppPalette(
    primary: Color(0xFF6B5BE0),
    onPrimary: Colors.white,
    accent: Color(0xFFA89CFF),
    primaryDeep: Color(0xFFD0C8FF),
    tint: Color(0xFF34306A),
    background: Color(0xFF121218),
    surface: Color(0xFF1D1C24),
    surfaceLow: Color(0xFF26252E),
    surfaceMid: Color(0xFF2F2E38),
    textPrimary: Color(0xFFE6E4EE),
    textSecondary: Color(0xFFC9C6D4),
    inputBorder: Color(0xFF8F8C9C),
    divider: Color(0xFF35343F),
    success: Color(0xFF5FD8B5),
    onSuccess: Color(0xFF00382B),
    successTint: Color(0xFF14382F),
    warning: Color(0xFFFFB59C),
    warningTint: Color(0xFF4A2418),
    danger: Color(0xFFFFB4AB),
    onDanger: Color(0xFF690005),
    dangerTint: Color(0xFF5A1D18),
    glass: Color(0x991D1C24),
    glassBorder: Color(0x24FFFFFF),
    cardShadow: [
      BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 4)),
    ],
    raisedShadow: [
      BoxShadow(color: Color(0x99000000), blurRadius: 24, offset: Offset(0, 8)),
    ],
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) => t < .5 ? this : other ?? this;
}

extension AppPaletteOf on BuildContext {
  /// The current appearance's colours; the light ones where no theme set any.
  AppPalette get colors =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
