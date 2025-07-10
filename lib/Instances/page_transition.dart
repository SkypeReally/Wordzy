import 'package:flutter/material.dart';
import 'package:animations/animations.dart'; // Add this in pubspec.yaml

import 'package:gmae_wordle/Instances/delayed_slide.dart';

/// Slide route transition
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

/// Fade route transition
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

/// Bottom navigation transition builder using FadeThrough
Widget buildTabTransition({
  required Widget child,
  required Animation<double> animation,
  required Animation<double> secondaryAnimation,
}) {
  return FadeThroughTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    child: child,
  );
}

/// Widget wrapper to apply bottom nav transition
class AnimatedTabSwitcher extends StatelessWidget {
  final Widget child;

  const AnimatedTabSwitcher({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation, secondaryAnimation) =>
          buildTabTransition(
            child: child,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
          ),
      child: child,
    );
  }
}
