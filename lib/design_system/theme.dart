import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'motion.dart';
import 'tokens.dart';

ColorScheme _scheme(AppPalette p, Brightness brightness) => ColorScheme(
  brightness: brightness,
  primary: p.primary,
  onPrimary: p.onPrimary,
  primaryContainer: p.tint,
  onPrimaryContainer: p.primaryDeep,
  // Chips, segments and the navigation indicator read the secondary roles.
  secondary: p.primaryDeep,
  onSecondary: p.onPrimary,
  secondaryContainer: p.tint,
  onSecondaryContainer: p.primaryDeep,
  tertiary: p.success,
  onTertiary: p.onSuccess,
  error: p.danger,
  onError: p.onDanger,
  errorContainer: p.dangerTint,
  onErrorContainer: p.danger,
  surface: p.surface,
  onSurface: p.textPrimary,
  onSurfaceVariant: p.textSecondary,
  surfaceContainerLowest: p.surface,
  surfaceContainerLow: p.surface,
  surfaceContainer: p.surface,
  surfaceContainerHigh: p.surface,
  surfaceContainerHighest: p.tint,
  outline: p.inputBorder,
  outlineVariant: p.divider,
  inverseSurface: p.textPrimary,
  onInverseSurface: p.background,
  inversePrimary: p.tint,
  surfaceTint: Colors.transparent,
);

ThemeData buildAppTheme([Brightness brightness = Brightness.light]) {
  final p = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
  const fieldRadius = BorderRadius.all(Radius.circular(AppRadii.sm));
  OutlineInputBorder field(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: color, width: width),
      );
  const tapSize = Size(kMinTapSize, kMinTapSize);
  const pill = StadiumBorder();
  final textTheme =
      const TextTheme(
        displaySmall: AppType.display,
        headlineSmall: AppType.title,
        titleLarge: AppType.title,
        titleMedium: AppType.cardTitle,
        titleSmall: AppType.label,
        bodyLarge: AppType.body,
        bodyMedium: AppType.body,
        bodySmall: AppType.caption,
        labelLarge: AppType.label,
        labelMedium: AppType.caption,
      ).apply(
        fontFamily: AppType.family,
        bodyColor: p.textPrimary,
        displayColor: p.textPrimary,
      );
  final label = textTheme.labelLarge!;
  return ThemeData(
    useMaterial3: true,
    colorScheme: _scheme(p, brightness),
    extensions: [p],
    fontFamily: AppType.family,
    textTheme: textTheme,
    scaffoldBackgroundColor: p.background,
    // No Material ripple or highlight: presses are shown by [Pressable].
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    pageTransitionsTheme: appPageTransitions,
    dividerTheme: DividerThemeData(color: p.divider),
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: p.textPrimary,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
      toolbarHeight: 64,
      systemOverlayStyle: brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.tint,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? p.primaryDeep
              : p.textSecondary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => AppType.label.copyWith(
          color: s.contains(WidgetState.selected)
              ? p.primaryDeep
              : p.textSecondary,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      // Wrapped, not cut off, at large text: the message must stay readable.
      helperMaxLines: 3,
      errorMaxLines: 3,
      filled: true,
      fillColor: p.surfaceLow,
      border: field(p.divider),
      enabledBorder: field(p.divider),
      disabledBorder: field(p.divider),
      focusedBorder: field(p.primary, 2),
      errorBorder: field(p.danger),
      focusedErrorBorder: field(p.danger, 2),
      labelStyle: textTheme.bodyLarge!.copyWith(color: p.textSecondary),
      helperStyle: textTheme.bodySmall!.copyWith(color: p.textSecondary),
      errorStyle: textTheme.bodySmall!.copyWith(color: p.danger),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: tapSize,
        shape: pill,
        textStyle: label,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: tapSize,
        shape: pill,
        textStyle: label,
        foregroundColor: p.primaryDeep,
        side: BorderSide(color: p.inputBorder),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: tapSize,
        shape: pill,
        textStyle: label,
        foregroundColor: p.primaryDeep,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surfaceLow,
      selectedColor: p.tint,
      // Selection shows in the fill and border; a tick would cover the avatar.
      showCheckmark: false,
      checkmarkColor: p.primaryDeep,
      labelStyle: label.copyWith(color: p.textPrimary),
      secondaryLabelStyle: label.copyWith(color: p.primaryDeep),
      shape: pill,
      side: WidgetStateBorderSide.resolveWith(
        (s) => BorderSide(
          color: s.contains(WidgetState.selected) ? p.primary : p.inputBorder,
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: pill,
        minimumSize: tapSize,
        textStyle: label,
        foregroundColor: p.textPrimary,
        selectedForegroundColor: p.primaryDeep,
        selectedBackgroundColor: p.tint,
        side: BorderSide(color: p.inputBorder),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedSuperellipseBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.lg)),
      ),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium!.copyWith(color: p.textSecondary),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
    ),
    timePickerTheme: TimePickerThemeData(backgroundColor: p.surface),
    popupMenuTheme: PopupMenuThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      textStyle: textTheme.bodyMedium,
      shape: const RoundedRectangleBorder(borderRadius: fieldRadius),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.textPrimary,
      contentTextStyle: textTheme.bodyMedium!.copyWith(color: p.background),
      actionTextColor: p.tint,
      shape: const RoundedRectangleBorder(borderRadius: fieldRadius),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.primary,
      foregroundColor: p.onPrimary,
      shape: pill,
      extendedTextStyle: label,
    ),
  );
}
