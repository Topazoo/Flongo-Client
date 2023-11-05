import 'package:flongo_client/app.dart';
import 'package:flongo_client/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'pages/config/page.dart';
import 'pages/home/page.dart';
import 'pages/login/page.dart';
import 'splash/page.dart';
import 'theme.dart';

final FlongoApp app = FlongoApp(
  router: AppRouter(
    routeBuilders: {
      '/_splash': (context, args) => const SplashScreen(),
      '/': (context, args) => LoginPage(),
      '/home': (context, args) => HomePage(),
      '/config': (context, args) => ConfigPage(),
    },
  ),
  initialRoute: '/_splash',
  appTheme: ThemeData(primarySwatch: AppTheme.primarySwatch),
);


void main() async {
  await dotenv.load(fileName: 'assets/.env');
  runApp(app);
}
