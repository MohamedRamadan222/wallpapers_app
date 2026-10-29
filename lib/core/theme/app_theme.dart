import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Dark-only theme matching the HTML prototype.
abstract final class AppTheme {
  static const _systemStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.phone,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.phone,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.phone,
        primary: AppColors.accent,
        onPrimary: AppColors.accentInk,
        onSurface: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.phone,
        foregroundColor: AppColors.text,
        elevation: 0,
        systemOverlayStyle: _systemStyle,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
    );
  }
}
