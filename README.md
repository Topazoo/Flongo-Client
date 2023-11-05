# Flongo Client

Seamless frontend for Flongo-Framework that provides out of the box widgets for connecting to the API, storing authentication sessions and more.

## Features

- Built in HTTP Client for connecting to the server
- Simple router that allows pages to be easily specified
- Easy custom animations and one-off transitions
- Abstract pages to handle rendering JSON data
- Works on mobile and web!

## Usage

You can see an example client defined in the  `/example` folder.

```dart
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
```

The application:

- Serves a default splash sceen on `/_splash`
- Renders a login page on `/` that connects to a Flongo Framework server
- Renders a dynamic navbar
- Renders a home page on `/` for authenticated users
- Renders a JSON List view page on `/config` for admin users with basic CRUD support

## Additional information

[View on Github](https://github.com/Topazoo/Flongo-Client)

For futher information please contact pswanson@ucdavis.edu!
