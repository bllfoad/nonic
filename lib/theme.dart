import 'package:flutter/material.dart';
import 'dart:ui';

class NonicColors {
  static const Color background = Color(0xFF0F231B);
  static const Color surface = Color(0xFF122A21);
  static const Color card = Color(0xFF12432E);
  static const Color primary = Color(0xFF1AE06C);
  static const Color primaryDark = Color(0xFF15B859);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CB3A8);
  static const Color outline = Color(0xFF1D3A2E);
}

ThemeData buildNonicTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: NonicColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: NonicColors.primary,
      surface: NonicColors.surface,
      secondary: NonicColors.card,
      outline: NonicColors.outline,
      onPrimary: Colors.black,
      onSurface: NonicColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: NonicColors.textPrimary,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NonicColors.surface,
      hintStyle: const TextStyle(color: NonicColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: NonicColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: NonicColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: NonicColors.primary),
      ),
      contentPadding: const EdgeInsets.all(20),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: NonicColors.card,
      inactiveTrackColor: NonicColors.outline,
      thumbColor: NonicColors.primary,
      overlayColor: Color(0x551AE06C),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NonicColors.primary,
        foregroundColor: Colors.black,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: NonicColors.textPrimary,
      displayColor: NonicColors.textPrimary,
    ).copyWith(
      headlineMedium: const TextStyle(fontWeight: FontWeight.w700),
    ),
    cardColor: NonicColors.card,
  );
}


class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? tint;
  const Glass({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.margin, this.borderRadius = 16, this.tint});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (tint ?? theme.colorScheme.surface).withOpacity(0.28),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

