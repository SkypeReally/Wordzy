import 'package:flutter/material.dart';

final ThemeData customLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.light,
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

final ThemeData customDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.dark,
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
