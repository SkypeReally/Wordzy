import 'package:flutter/material.dart';
import 'package:gmae_wordle/Instances/delayed_slide.dart';

Route createSlideRoute(
  Widget page, {
  bool useDelay = false,
  Duration duration = const Duration(milliseconds: 500),
  Offset beginOffset = const Offset(1.0, 0.0),
}) {
  return PageRouteBuilder(
    transitionDuration: duration,
    pageBuilder: (_, __, ___) =>
        useDelay ? DelayedSlidePage(child: page) : page,
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(
        begin: beginOffset,
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

Route createFadeRoute(
  Widget page, {
  Duration duration = const Duration(milliseconds: 300),
}) {
  return PageRouteBuilder(
    transitionDuration: duration,
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
