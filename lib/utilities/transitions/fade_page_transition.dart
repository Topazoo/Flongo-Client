import 'package:flutter/material.dart';

class FadePageTransition {
  static Widget Function(BuildContext, Animation<double>, Animation<double>, Widget) transitionsBuilder = (context, animation, secondaryAnimation, child) =>
    FadeTransition(
      opacity: animation,
      child: child,
    );
}
