
import 'package:flongo_client/pages/base_page.dart';
import 'package:flongo_client/utilities/http_client.dart';
import 'package:flongo_client/widgets/navbar/app_navbar.dart';
import 'package:flutter/material.dart';

import '../../navbar.dart';

class HomePage extends BasePage {
  @override
  final bool authenticationRequired = true;
  @override
  final AppNavBar navbar = NavBar();

  HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends BasePageState {
  @override
  Widget getPageWidget(BuildContext context) {
    return Text('Welcome Home: ${HTTPClient.getUsername()}');
  }
}
