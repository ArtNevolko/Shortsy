import 'package:flutter/material.dart';
import '../shared/widgets/transitions.dart';

class AppDesign {
  // Цвета базовой тёмной темы
  static const Color bg = Color(0xFF0B0F14);
  static const Color primary = Color(0xFF7DD3FC);
  static const Color secondary = Color(0xFFA78BFA);
  static const Color deepBlack = Color(0xFF0A0A0A);
  static const Color mysticViolet1 = Color(0xFF7C3AED);
  static const Color mysticViolet2 = Color(0xFF4C1D95);
  static const Color lavenderHaze = Color(0xFFB39DDB);
  static const Color silverGray = Color(0xFFBFC7CC);
  static const Color glossyWhite = Color(0xFFFFFFFF);

  // Единый радиус
  static const double radius = 18;
  static const BorderRadius borderRadius =
      BorderRadius.all(Radius.circular(radius));

  // Spacing scale
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;

  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);

  // Градиенты и эффекты
  static const Gradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, primary],
  );
  static const Gradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
  );

  static const Gradient premiumLight = RadialGradient(
    colors: [Color(0x22FFFFFF), Color(0x00000000)],
    radius: 1.2,
    center: Alignment(-0.6, -0.6),
  );

  static const Gradient mysticGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mysticViolet1, mysticViolet2],
  );

  static const Gradient lavenderSmoke = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x33B39DDB), Color(0x001B1B1B)],
  );

  static Gradient backgroundGradientFor(Brightness b) {
    if (b == Brightness.light) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFFF4F6F8)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0A0A0A), Color(0xFF12121A)],
    );
  }

  static Gradient subtleVignetteFor(Brightness b) {
    if (b == Brightness.light) {
      return const RadialGradient(
        colors: [Color(0x10000000), Color(0x00000000)],
        radius: 1.2,
        center: Alignment(0, 0.2),
      );
    }
    return const RadialGradient(
      colors: [Color(0x22000000), Color(0x00000000)],
      radius: 1.1,
      center: Alignment(0, 0.2),
    );
  }

  // Унифицированная типографика + кнопки
  static ThemeData applyTypography(ThemeData base) {
    final ts = base.textTheme;
    return base.copyWith(
      textTheme: ts.copyWith(
        titleLarge:
            ts.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 22),
        titleMedium:
            ts.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
        bodyMedium: ts.bodyMedium?.copyWith(fontSize: 14, height: 1.35),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white60),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
    );
  }

  static ThemeData buildTheme({required bool light}) {
    final base = light ? ThemeData.light() : ThemeData.dark();
    final bg = light ? Colors.white : deepBlack;
    final fg = light ? Colors.black87 : Colors.white;
    return base.copyWith(
      brightness: light ? Brightness.light : Brightness.dark,
      pageTransitionsTheme: AppTransitions.silk(),
      scaffoldBackgroundColor: bg,
      appBarTheme:
          AppBarTheme(backgroundColor: bg, foregroundColor: fg, elevation: 0),
      textTheme: base.textTheme.apply(
        bodyColor: fg,
        displayColor: fg,
      ),
      iconTheme: IconThemeData(color: fg),
      splashFactory: InkSparkle.splashFactory,
      splashColor: light ? Colors.black12 : Colors.white10,
      highlightColor: light ? Colors.black12 : Colors.white12,
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: secondary,
        surface: bg,
        onSurface: fg,
        onPrimary: Colors.white,
      ),
    );
  }

  static ThemeData lightTheme() => buildTheme(light: true);
  static ThemeData darkTheme() => buildTheme(light: false);

  // Backward-compatible static gradients for legacy widgets
  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0A), Color(0xFF12121A)],
  );

  static const Gradient subtleVignette = RadialGradient(
    colors: [Color(0x22000000), Color(0x00000000)],
    radius: 1.1,
    center: Alignment(0, 0.2),
  );

  // Text glow fallback for legacy usages
  static List<Shadow> get glow => const [
        Shadow(color: Color(0x55000000), blurRadius: 8, offset: Offset(0, 2)),
      ];

  static List<BoxShadow> get boxGlow => const [
        BoxShadow(
            color: Color(0x55000000), blurRadius: 8, offset: Offset(0, 2)),
      ];
}
