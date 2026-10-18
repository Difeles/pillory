import 'package:flutter/material.dart';

import 'tokens.dart';

const _scheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  onPrimary: Colors.white,
  primaryContainer: AppColors.tint,
  onPrimaryContainer: AppColors.primaryDeep,
  // Chips, segments and the navigation indicator read the secondary roles.
  secondary: AppColors.primaryDeep,
  onSecondary: Colors.white,
  secondaryContainer: AppColors.tint,
  onSecondaryContainer: AppColors.primaryDeep,
  tertiary: AppColors.success,
  onTertiary: Colors.white,
  error: AppColors.danger,
  onError: Colors.white,
  errorContainer: AppColors.dangerTint,
  onErrorContainer: AppColors.danger,
  surface: AppColors.surface,
  onSurface: AppColors.textPrimary,
  onSurfaceVariant: AppColors.textSecondary,
  surfaceContainerLowest: AppColors.surface,
  surfaceContainerLow: AppColors.surface,
  surfaceContainer: AppColors.surface,
  surfaceContainerHigh: AppColors.surface,
  surfaceContainerHighest: AppColors.tint,
  outline: AppColors.inputBorder,
  outlineVariant: AppColors.divider,
  inverseSurface: AppColors.textPrimary,
  onInverseSurface: Colors.white,
  inversePrimary: AppColors.tint,
  surfaceTint: Colors.transparent,
);

ThemeData buildAppTheme() {
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
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );
  final label = textTheme.labelLarge!;
  return ThemeData(
    useMaterial3: true,
    colorScheme: _scheme,
    fontFamily: AppType.family,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.background,
    dividerTheme: const DividerThemeData(color: AppColors.divider),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.tint,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? AppColors.primaryDeep
              : AppColors.textSecondary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => textTheme.labelMedium!.copyWith(
          fontWeight: FontWeight.w600,
          color: s.contains(WidgetState.selected)
              ? AppColors.primaryDeep
              : AppColors.textSecondary,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: field(AppColors.inputBorder),
      enabledBorder: field(AppColors.inputBorder),
      disabledBorder: field(AppColors.divider),
      focusedBorder: field(AppColors.primary, 2),
      errorBorder: field(AppColors.danger),
      focusedErrorBorder: field(AppColors.danger, 2),
      labelStyle: textTheme.bodyLarge!.copyWith(color: AppColors.textSecondary),
      helperStyle: textTheme.bodySmall!.copyWith(
        color: AppColors.textSecondary,
      ),
      errorStyle: textTheme.bodySmall!.copyWith(color: AppColors.danger),
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
        foregroundColor: AppColors.primaryDeep,
        side: const BorderSide(color: AppColors.inputBorder),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: tapSize,
        shape: pill,
        textStyle: label,
        foregroundColor: AppColors.primaryDeep,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.tint,
      checkmarkColor: AppColors.primaryDeep,
      labelStyle: label.copyWith(color: AppColors.textPrimary),
      secondaryLabelStyle: label.copyWith(color: AppColors.primaryDeep),
      shape: pill,
      side: WidgetStateBorderSide.resolveWith(
        (s) => BorderSide(
          color: s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.inputBorder,
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        minimumSize: tapSize,
        textStyle: label,
        foregroundColor: AppColors.textPrimary,
        selectedForegroundColor: AppColors.primaryDeep,
        selectedBackgroundColor: AppColors.tint,
        side: const BorderSide(color: AppColors.inputBorder),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.lg)),
      ),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium!.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: AppColors.surface,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      textStyle: textTheme.bodyMedium,
      shape: const RoundedRectangleBorder(borderRadius: fieldRadius),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: textTheme.bodyMedium!.copyWith(color: Colors.white),
      actionTextColor: AppColors.tint,
      shape: const RoundedRectangleBorder(borderRadius: fieldRadius),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: pill,
      extendedTextStyle: label,
    ),
  );
}
