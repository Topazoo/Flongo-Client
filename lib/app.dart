
import 'package:flongo_client/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FlongoApp extends StatelessWidget {
  static final env = dotenv.env;

  final String initialRoute;
  final AppRouter router;
  final ThemeData appTheme;

  const FlongoApp({
    Key? key,
    required this.router,
    required this.initialRoute,
    required this.appTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: env['APP_NAME'] ?? 'App Name',
      theme: appTheme,
      onGenerateRoute: router.generateRoute,
      initialRoute: initialRoute,
    );
  }
}