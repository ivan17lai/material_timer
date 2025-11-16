import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff006971),
      surfaceTint: Color(0xff006971),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff14e1f2),
      onPrimaryContainer: Color(0xff006068),
      secondary: Color(0xff2f666c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffb2e9f0),
      onSecondaryContainer: Color(0xff346b71),
      tertiary: Color(0xff69548a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffdac1ff),
      onTertiaryContainer: Color(0xff614c81),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff3fbfc),
      onSurface: Color(0xff161d1e),
      onSurfaceVariant: Color(0xff3b494b),
      outline: Color(0xff6b7a7c),
      outlineVariant: Color(0xffbac9cb),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2a3233),
      inversePrimary: Color(0xff00dbec),
      primaryFixed: Color(0xff88f3ff),
      onPrimaryFixed: Color(0xff001f23),
      primaryFixedDim: Color(0xff00dbec),
      onPrimaryFixedVariant: Color(0xff004f56),
      secondaryFixed: Color(0xffb5ecf3),
      onSecondaryFixed: Color(0xff001f23),
      secondaryFixedDim: Color(0xff99d0d7),
      onSecondaryFixedVariant: Color(0xff114e54),
      tertiaryFixed: Color(0xffecdcff),
      onTertiaryFixed: Color(0xff240f43),
      tertiaryFixedDim: Color(0xffd4bcf9),
      onTertiaryFixedVariant: Color(0xff513d71),
      surfaceDim: Color(0xffd4dbdc),
      surfaceBright: Color(0xfff3fbfc),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeef5f6),
      surfaceContainer: Color(0xffe8eff0),
      surfaceContainerHigh: Color(0xffe2eaea),
      surfaceContainerHighest: Color(0xffdce4e5),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003d42),
      surfaceTint: Color(0xff006971),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff007983),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003d42),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff3f757b),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff402c5f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff78639a),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff3fbfc),
      onSurface: Color(0xff0b1213),
      onSurfaceVariant: Color(0xff2b393a),
      outline: Color(0xff475557),
      outlineVariant: Color(0xff617072),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2a3233),
      inversePrimary: Color(0xff00dbec),
      primaryFixed: Color(0xff007983),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff005e66),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff3f757b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff245c63),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff78639a),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff5f4b80),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc0c8c9),
      surfaceBright: Color(0xfff3fbfc),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeef5f6),
      surfaceContainer: Color(0xffe2eaea),
      surfaceContainerHigh: Color(0xffd7dedf),
      surfaceContainerHighest: Color(0xffcbd3d4),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003236),
      surfaceTint: Color(0xff006971),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff005158),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003236),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff145157),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff352254),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff533f74),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff3fbfc),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff212e30),
      outlineVariant: Color(0xff3d4c4d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2a3233),
      inversePrimary: Color(0xff00dbec),
      primaryFixed: Color(0xff005158),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff00393e),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff145157),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff00393e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff533f74),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff3c285b),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb2babb),
      surfaceBright: Color(0xfff3fbfc),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffebf2f3),
      surfaceContainer: Color(0xffdce4e5),
      surfaceContainerHigh: Color(0xffced6d7),
      surfaceContainerHighest: Color(0xffc0c8c9),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa6f5ff),
      surfaceTint: Color(0xff00dbec),
      onPrimary: Color(0xff00363b),
      primaryContainer: Color(0xff14e1f2),
      onPrimaryContainer: Color(0xff006068),
      secondary: Color(0xff99d0d7),
      onSecondary: Color(0xff00363b),
      secondaryContainer: Color(0xff145157),
      onSecondaryContainer: Color(0xff8bc2c8),
      tertiary: Color(0xfff1e3ff),
      onTertiary: Color(0xff3a2659),
      tertiaryContainer: Color(0xffdac1ff),
      onTertiaryContainer: Color(0xff614c81),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0d1515),
      onSurface: Color(0xffdce4e5),
      onSurfaceVariant: Color(0xffbac9cb),
      outline: Color(0xff849395),
      outlineVariant: Color(0xff3b494b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdce4e5),
      inversePrimary: Color(0xff006971),
      primaryFixed: Color(0xff88f3ff),
      onPrimaryFixed: Color(0xff001f23),
      primaryFixedDim: Color(0xff00dbec),
      onPrimaryFixedVariant: Color(0xff004f56),
      secondaryFixed: Color(0xffb5ecf3),
      onSecondaryFixed: Color(0xff001f23),
      secondaryFixedDim: Color(0xff99d0d7),
      onSecondaryFixedVariant: Color(0xff114e54),
      tertiaryFixed: Color(0xffecdcff),
      onTertiaryFixed: Color(0xff240f43),
      tertiaryFixedDim: Color(0xffd4bcf9),
      onTertiaryFixedVariant: Color(0xff513d71),
      surfaceDim: Color(0xff0d1515),
      surfaceBright: Color(0xff333a3b),
      surfaceContainerLowest: Color(0xff080f10),
      surfaceContainerLow: Color(0xff161d1e),
      surfaceContainer: Color(0xff1a2122),
      surfaceContainerHigh: Color(0xff242b2c),
      surfaceContainerHighest: Color(0xff2f3637),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa6f5ff),
      surfaceTint: Color(0xff00dbec),
      onPrimary: Color(0xff003438),
      primaryContainer: Color(0xff14e1f2),
      onPrimaryContainer: Color(0xff004147),
      secondary: Color(0xffafe6ed),
      onSecondary: Color(0xff002b2f),
      secondaryContainer: Color(0xff6499a0),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff1e3ff),
      onTertiary: Color(0xff372356),
      tertiaryContainer: Color(0xffdac1ff),
      onTertiaryContainer: Color(0xff433063),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0d1515),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd0dfe1),
      outline: Color(0xffa5b5b7),
      outlineVariant: Color(0xff849395),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdce4e5),
      inversePrimary: Color(0xff005057),
      primaryFixed: Color(0xff88f3ff),
      onPrimaryFixed: Color(0xff001417),
      primaryFixedDim: Color(0xff00dbec),
      onPrimaryFixedVariant: Color(0xff003d42),
      secondaryFixed: Color(0xffb5ecf3),
      onSecondaryFixed: Color(0xff001417),
      secondaryFixedDim: Color(0xff99d0d7),
      onSecondaryFixedVariant: Color(0xff003d42),
      tertiaryFixed: Color(0xffecdcff),
      onTertiaryFixed: Color(0xff190338),
      tertiaryFixedDim: Color(0xffd4bcf9),
      onTertiaryFixedVariant: Color(0xff402c5f),
      surfaceDim: Color(0xff0d1515),
      surfaceBright: Color(0xff3e4647),
      surfaceContainerLowest: Color(0xff030809),
      surfaceContainerLow: Color(0xff181f20),
      surfaceContainer: Color(0xff22292a),
      surfaceContainerHigh: Color(0xff2c3435),
      surfaceContainerHighest: Color(0xff373f40),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc7f9ff),
      surfaceTint: Color(0xff00dbec),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff14e1f2),
      onPrimaryContainer: Color(0xff001b1e),
      secondary: Color(0xffc7f9ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff95ccd3),
      onSecondaryContainer: Color(0xff000e10),
      tertiary: Color(0xfff7ecff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffdac1ff),
      onTertiaryContainer: Color(0xff200b3e),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0d1515),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe3f3f5),
      outlineVariant: Color(0xffb6c5c7),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdce4e5),
      inversePrimary: Color(0xff005057),
      primaryFixed: Color(0xff88f3ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff00dbec),
      onPrimaryFixedVariant: Color(0xff001417),
      secondaryFixed: Color(0xffb5ecf3),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff99d0d7),
      onSecondaryFixedVariant: Color(0xff001417),
      tertiaryFixed: Color(0xffecdcff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffd4bcf9),
      onTertiaryFixedVariant: Color(0xff190338),
      surfaceDim: Color(0xff0d1515),
      surfaceBright: Color(0xff4a5152),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1a2122),
      surfaceContainer: Color(0xff2a3233),
      surfaceContainerHigh: Color(0xff353d3e),
      surfaceContainerHighest: Color(0xff414849),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
