import 'package:flutter/material.dart';

class AppTheme {
  // Paleta: índigo/morado + acentos rosa pastel y turquesa
  static const indigo = Color(0xFF4F46E5);
  static const purple = Color(0xFF7C3AED);
  static const pastelPink = Color(0xFFF9A8D4);
  static const turquoise = Color(0xFF2DD4BF);

  static const bg = Color(0xFFF7F4FF); // lila muy suave / crema-lila
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: indigo,
      brightness: Brightness.light,
    ).copyWith(
      primary: indigo,
      secondary: turquoise,
      tertiary: pastelPink,
      surface: Colors.white,
      background: bg,
      error: const Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: const Color(0xFF052F2A),
      onSurface: text,
      onBackground: text,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,

      // Tipografía base más “app”
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontWeight: FontWeight.w700),
      ).apply(
        bodyColor: text,
        displayColor: text,
      ),

      // AppBar (el gradiente lo pintas en cada pantalla con flexibleSpace)
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Cards tipo mock
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.black.withOpacity(.04)),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withOpacity(.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withOpacity(.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: turquoise, width: 2),
        ),
        labelStyle: const TextStyle(color: muted),
        hintStyle: TextStyle(color: muted.withOpacity(.8)),
      ),

      // Filled buttons (principal índigo)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: indigo,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      // Outlined buttons (borde índigo)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: indigo,
          side: const BorderSide(color: indigo, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: indigo,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      // Chips tipo “píldora” con acentos
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: Colors.black.withOpacity(.06)),
        backgroundColor: Colors.white,
        selectedColor: turquoise.withOpacity(.18),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        secondaryLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),

      // TabBar (para pantallas tipo “Mis Solicitudes” con filtros)
      tabBarTheme: TabBarTheme(
        labelColor: indigo,
        unselectedLabelColor: muted,
        indicatorColor: indigo,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),

      // BottomNavigation estilo mock
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: indigo,
        unselectedItemColor: muted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Snackbars más “pro”
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF111827),
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),

      // Dividers suaves
      dividerTheme: DividerThemeData(
        color: Colors.black.withOpacity(.06),
        thickness: 1,
      ),
    );
  }

  /// ✅ Helper opcional: AppBar con gradiente idéntico a mock
  /// Úsalo así:
  /// AppBar(flexibleSpace: AppTheme.gradientAppBarBackground(), ...)
  static Widget gradientAppBarBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [indigo, purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
