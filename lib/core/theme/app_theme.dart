import 'package:flutter/material.dart';

import 'app_design_tokens.dart';
import 'masrofy_theme_extension.dart';

class AppTheme {
  const AppTheme._();

  static const _seedColor = Color(0xFF006D77);
  static const _incomeColor = Color(0xFF2A9D8F);
  static const _expenseColor = Color(0xFFE76F51);
  static const _savingsColor = Color(0xFF52796F);
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
      extension: MasrofyThemeExtension(
        income: _incomeColor,
        expense: _expenseColor,
        savings: _savingsColor,
        warning: _warningColor,
        success: _successColor,
        danger: _dangerColor,
        info: _infoColor,
        budgetSafe: _successColor,
        budgetWarning: const Color(0xFF9A6700),
        budgetExceeded: _dangerColor,
        elevatedSurface: colorScheme.surfaceContainerLow,
        cardBorder: colorScheme.outlineVariant.withValues(alpha: 0.72),
        divider: colorScheme.outlineVariant.withValues(alpha: 0.7),
        subtleText: colorScheme.onSurfaceVariant,
        maskedAmount: const Color(0xFF6B7280),
        disabled: colorScheme.onSurface.withValues(alpha: 0.38),
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
      extension: MasrofyThemeExtension(
        income: Color(0xFF7DD3C7),
        expense: Color(0xFFFFA08A),
        savings: const Color(0xFFA7C4B5),
        warning: Color(0xFFF3D77C),
        success: Color(0xFF81C784),
        danger: Color(0xFFEF9A9A),
        info: Color(0xFF90CAF9),
        budgetSafe: const Color(0xFF81C784),
        budgetWarning: const Color(0xFFFFD166),
        budgetExceeded: const Color(0xFFEF9A9A),
        elevatedSurface: colorScheme.surfaceContainerLow,
        cardBorder: colorScheme.outlineVariant.withValues(alpha: 0.5),
        divider: colorScheme.outlineVariant.withValues(alpha: 0.58),
        subtleText: colorScheme.onSurfaceVariant,
        maskedAmount: const Color(0xFF9CA3AF),
        disabled: colorScheme.onSurface.withValues(alpha: 0.42),
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
        backgroundColor: colorScheme.surface.withValues(alpha: 0.98),
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.none,
        color: extension.elevatedSurface,
        margin: EdgeInsets.zero,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.card,
          side: BorderSide(color: extension.cardBorder),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: extension.divider,
        space: AppSpacing.lg,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: extension.elevatedSurface,
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
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
        ),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppSpacing.sm,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.pill,
          side: BorderSide(color: extension.cardBorder),
        ),
        showCheckmark: false,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: colorScheme.primary);
            }
            return BorderSide(color: extension.cardBorder);
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.card),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.sheet),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: AppElevation.low,
        highlightElevation: AppElevation.medium,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.sheet),
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
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
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
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
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
