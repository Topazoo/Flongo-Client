import 'package:flutter/material.dart';

class FiveDotsTransition {
  static Widget Function(BuildContext, Animation<double>, Animation<double>, Widget) transitionsBuilder = (context, animation, secondaryAnimation, child) =>
    Stack(
      children: [
        // Main content with delayed fade-in
        FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.5, 1.0), // Delay fade-in of the page content
            ),
          ),
          child: child,
        ),
        // Five dots transition
        Positioned.fill(
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, child) {
              return Opacity(
                opacity: (1.0 - animation.value).clamp(0.0, 1.0),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      // Adjust delay for each dot for a total of 5 dots
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: _DotTransition(
                          animation: animation,
                          delay: index * 0.100, // Adjusted delay for each dot
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
}

class _DotTransition extends StatelessWidget {
  final Animation<double> animation;
  final double delay;

  const _DotTransition({
    Key? key,
    required this.animation,
    required this.delay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        double opacity = 0.0;
        if (animation.value > delay && animation.value < 0.5) {
          opacity = (animation.value - delay) / (0.5 - delay);
        }
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
