import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
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

class AnimatedTabSwitcher extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final int previousIndex;

  const AnimatedTabSwitcher({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.previousIndex,
  });

  @override
  Widget build(BuildContext context) {
    final bool slideFromRight = currentIndex > previousIndex;

    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 300),
      reverse: !slideFromRight,
      transitionBuilder: (child, animation, secondaryAnimation) {
        const offset = Offset(1.0, 0.0);
        final tween = Tween<Offset>(
          begin: slideFromRight ? offset : -offset,
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      child: child,
    );
  }
}
