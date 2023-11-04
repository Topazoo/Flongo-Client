import 'package:flutter/material.dart';

class AppRouter {
  final Map<String, Widget Function(BuildContext, Map)> routeBuilders;
  final RouteTransitionsBuilder? defaultTransitionBuilder;
  final Duration defaultTransitionDuration;

  AppRouter({
    required this.routeBuilders,
    this.defaultTransitionBuilder,
    this.defaultTransitionDuration = const Duration(milliseconds: 300),
  });

  Route<dynamic>? generateRoute(RouteSettings settings) {
    final routeArgs = settings.arguments is Map ? settings.arguments as Map : {};
    final pageBuilder = routeBuilders[settings.name];

    if (pageBuilder != null) {
      return _buildRoute(settings.name!, routeArgs, pageBuilder);
    }

    // Handle unknown route
    return MaterialPageRoute(builder: (context) => const Scaffold(body: Center(child: Text('404: Not Found!'))));
  }

  PageRoute _buildRoute(String url, Map args, Widget Function(BuildContext, Map) pageBuilder) {
    final transitionBuilder = args['_animation'] as RouteTransitionsBuilder? ?? defaultTransitionBuilder;
    final transitionDuration = Duration(milliseconds: args['_animation_duration'] as int? ?? defaultTransitionDuration.inMilliseconds);

    if (transitionBuilder != null) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => pageBuilder(context, args),
        settings: RouteSettings(name: url),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => 
          transitionBuilder(context, animation, secondaryAnimation, child),
        transitionDuration: transitionDuration,
      );
    } else {
      return MaterialPageRoute(
        builder: (context) => pageBuilder(context, args),
        settings: RouteSettings(name: url),
      );
    }
  }
}
