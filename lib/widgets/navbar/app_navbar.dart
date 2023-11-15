import 'package:flongo_client/widgets/navbar/nav_bar_item.dart';
import 'package:flutter/material.dart';

class AppNavBar {
  final List<NavBarItem> navbarItems;

  const AppNavBar({
    this.navbarItems = const []
  });

  List<NavBarItem> getNavbarItems() => navbarItems;

  Widget getNavbarHeader() => const DrawerHeader(child: SizedBox(height: 10));
}