import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flongo_client/utilities/transitions/fade_page_transition.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SplashScreen extends StatefulWidget {
  final String baseURL;
  final String? appName;

  const SplashScreen({super.key, this.appName, this.baseURL='/'});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static final env = dotenv.env;
  
  AnimationController? _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller!);

    // Navigate to the next page after a delay
    Timer(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacementNamed(
        widget.baseURL,
        arguments: {'_animation': FadePageTransition.transitionsBuilder}
      );
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedBuilder(
                animation: _controller!,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _controller!.value * 2.0 * 3.1415927,
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 100.0, // Adjust the size of the gear
                  height: 100.0, // Adjust the size of the gear
                  child: Image.asset('assets/images/gear.png'),
                ),
              ),
              const SizedBox(height: 20), // Spacing between the gear and text
              Text(
                "Loading: ${widget.appName ?? env['APP_NAME'] ?? 'App Name'}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
