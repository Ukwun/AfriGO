import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transitions for GoRouter
/// Provides modern, smooth transitions between screens

/// Slide transition from right
CustomTransitionPage<dynamic> slideRightTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut)),
        ),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
  );
}

/// Slide transition from left
CustomTransitionPage<dynamic> slideLeftTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut)),
        ),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
  );
}

/// Fade transition
CustomTransitionPage<dynamic> fadeTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
  );
}

/// Scale + Fade transition (great for modal-like screens)
CustomTransitionPage<dynamic> scaleTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: animation.drive(
          Tween<double>(begin: 0.8, end: 1).chain(
            CurveTween(curve: Curves.easeOutCubic),
          ),
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 350),
  );
}

/// Slide up + Fade transition (for bottom-to-top screens)
CustomTransitionPage<dynamic> slideUpTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 350),
  );
}
