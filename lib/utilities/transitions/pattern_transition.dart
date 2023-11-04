import 'package:flutter/material.dart';

class FuturisticPatternTransition {
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
        // Futuristic pattern transition
        Positioned.fill(
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, child) {
              return Opacity(
                opacity: (1.0 - animation.value).clamp(0.0, 1.0),
                child: Center(
                  child: Transform.scale(
                    scale: animation.value * 1.5, // Scale up the pattern during the animation
                    child: _FuturisticPatternShape(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
}

class _FuturisticPatternShape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _FuturisticPatternClipper(),
      child: Container(
        width: 150,
        height: 150,
        color: Colors.black,
      ),
    );
  }
}

class _FuturisticPatternClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Create an interconnected polygon pattern here
    // This is an example, you might want to design your own pattern

    final double width = size.width;
    final double height = size.height;
    final double sideLength = width / 3;

    // Top triangle
    path.moveTo(width / 2, 0);
    path.lineTo(sideLength, height / 2);
    path.lineTo(2 * sideLength, height / 2);
    path.close();

    // Bottom triangle
    path.moveTo(width / 2, height);
    path.lineTo(sideLength, height / 2);
    path.lineTo(2 * sideLength, height / 2);
    path.close();

    // Left triangle
    path.moveTo(0, height / 2);
    path.lineTo(sideLength, height / 4);
    path.lineTo(sideLength, 3 * height / 4);
    path.close();

    // Right triangle
    path.moveTo(width, height / 2);
    path.lineTo(2 * sideLength, height / 4);
    path.lineTo(2 * sideLength, 3 * height / 4);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
