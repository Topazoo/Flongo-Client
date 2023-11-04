import 'package:flutter/material.dart';

class FadeToBlackTransition {
  static Widget Function(BuildContext, Animation<double>, Animation<double>, Widget) transitionsBuilder = (context, animation, secondaryAnimation, child) =>
    AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        if (animation.isCompleted) {
          // Once the animation is completed, just return the child (i.e., the page)
          return child;
        }

        // Adjusted the curve for smoother transition
        Animation<double> fadeOutAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.ease,
        );

        return Stack(
          children: [
            // Main content fading out
            FadeTransition(
              opacity: fadeOutAnimation,
              child: child,
            ),
            // Black background fading in and then out
            Positioned.fill(
              child: FadeTransition(
                opacity: Tween<double>(begin: .4, end: .0).animate(
                  CurvedAnimation(
                    parent: animation,
                    // This will start fading in the background halfway through the main content fading out
                    curve: const Interval(0, 1, curve: Curves.easeInCirc),
                  ),
                ),
                child: Container(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
}
