import 'package:flutter/material.dart';

import 'app_design_tokens.dart';
import 'masrofy_theme_extension.dart';

class AppTheme {
  const AppTheme._();

  static const _seedColor = Color(0xFF006D77);
  static const _incomeColor = Color(0xFF2A9D8F);
  static const _expenseColor = Color(0xFFE76F51);
  static const _warningColor = Color(0xFFE9C46A);
  static const _successColor = Color(0xFF2E7D32);
  static const _dangerColor = Color(0xFFC62828);
  static const _infoColor = Color(0xFF1565C0);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      extension: const MasrofyThemeExtension(
        income: _incomeColor,
        expense: _expenseColor,
        warning: _warningColor,
        success: _successColor,
        danger: _dangerColor,
        info: _infoColor,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      extension: const MasrofyThemeExtension(
        income: Color(0xFF7DD3C7),
        expense: Color(0xFFFFA08A),
        warning: Color(0xFFF3D77C),
        success: Color(0xFF81C784),
        danger: Color(0xFFEF9A9A),
        info: Color(0xFF90CAF9),
      ),
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required MasrofyThemeExtension extension,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.standard,
      extensions: <ThemeExtension<dynamic>>[extension],
      textTheme: _textTheme(colorScheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.low,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.none,
        color: colorScheme.surfaceContainerHighest,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: AppRadii.card,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.card,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.card,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppSpacing.sm,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: AppElevation.none,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    return TextTheme(
      headlineMedium: TextStyle(
        fontSize: 30,
        height: 1.18,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: colorScheme.onSurface,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
