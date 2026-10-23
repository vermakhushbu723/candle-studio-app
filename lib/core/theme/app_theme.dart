import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography. The app uses Plus Jakarta Sans for almost everything (like native shopping apps);
/// Playfair Display only for a few brand moments, Cinzel for the wordmark.
class AppText {
  AppText._();

  static TextStyle serif({double size = 24, FontWeight weight = FontWeight.w500, Color color = AppColors.charcoal, double height = 1.15, FontStyle? style}) =>
      GoogleFonts.playfairDisplay(fontSize: size, fontWeight: weight, color: color, height: height, fontStyle: style);

  static TextStyle sans({double size = 14, FontWeight weight = FontWeight.w400, Color color = AppColors.charcoal, double height = 1.4}) =>
      GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: weight, color: color, height: height);

  static TextStyle brand({double size = 20, Color color = AppColors.terracotta}) =>
      GoogleFonts.cinzel(fontSize: size, fontWeight: FontWeight.w600, color: color, letterSpacing: size * 0.14);

  /// Screen section titles ("Bestsellers", "Shop by category").
  static TextStyle title({double size = 17, Color color = AppColors.charcoal}) => sans(size: size, weight: FontWeight.w700, color: color, height: 1.25);

  /// Small uppercase label.
  static TextStyle eyebrow({Color color = AppColors.terracotta}) =>
      GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 1.4);

  static TextStyle muted({double size = 13}) => sans(size: size, color: AppColors.ash);
}

class AppTheme {
  AppTheme._();

  /// Page background — light warm grey so white cards stand out (app look).
  static const background = Color(0xFFF7F3F0);
  static const radius = 14.0;

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(bodyColor: AppColors.charcoal, displayColor: AppColors.charcoal);
    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: w),
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.terracotta,
        primary: AppColors.terracotta,
        onPrimary: Colors.white,
        secondary: AppColors.caramel,
        surface: Colors.white,
        onSurface: AppColors.charcoal,
        error: AppColors.danger,
      ),
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        centerTitle: false,
        titleSpacing: 4,
        titleTextStyle: AppText.sans(size: 18, weight: FontWeight.w700),
        systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFEFE6DE), thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.terracotta,
        titleTextStyle: AppText.sans(size: 15, weight: FontWeight.w500),
        subtitleTextStyle: AppText.muted(size: 12.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minLeadingWidth: 24,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.mist,
          elevation: 0,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: rounded,
          textStyle: AppText.sans(size: 15, weight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.terracotta,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          side: const BorderSide(color: AppColors.terracotta),
          shape: rounded,
          textStyle: AppText.sans(size: 15, weight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.terracotta,
          textStyle: AppText.sans(weight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: AppText.muted(size: 14),
        labelStyle: AppText.sans(color: AppColors.ash),
        floatingLabelStyle: AppText.sans(color: AppColors.terracotta, weight: FontWeight.w600),
        border: border(AppColors.linen),
        enabledBorder: border(AppColors.linen),
        focusedBorder: border(AppColors.terracotta, 1.5),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 1.5),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.charcoal,
        side: const BorderSide(color: AppColors.linen),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: AppText.sans(size: 13, weight: FontWeight.w600),
        secondaryLabelStyle: AppText.sans(size: 13, weight: FontWeight.w600, color: Colors.white),
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.charcoal,
        contentTextStyle: AppText.sans(color: AppColors.cream),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.mist,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.terracotta : Colors.white),
        side: const BorderSide(color: AppColors.mist, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.terracotta : AppColors.mist)),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.terracotta : AppColors.mist),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: const SliderThemeData(activeTrackColor: AppColors.terracotta, thumbColor: AppColors.terracotta, inactiveTrackColor: AppColors.linen),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.terracotta),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.terracotta,
        unselectedLabelColor: AppColors.ash,
        indicatorColor: AppColors.terracotta,
        labelStyle: AppText.sans(size: 14, weight: FontWeight.w700),
        unselectedLabelStyle: AppText.sans(size: 14, weight: FontWeight.w500),
        dividerColor: const Color(0xFFEFE6DE),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.sand,
        elevation: 3,
        shadowColor: Colors.black26,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => AppText.sans(size: 11, weight: FontWeight.w700, color: s.contains(WidgetState.selected) ? AppColors.terracotta : AppColors.ash),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(size: 24, color: s.contains(WidgetState.selected) ? AppColors.terracotta : AppColors.ash),
        ),
      ),
    );
  }
}
