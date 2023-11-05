import 'package:flutter/material.dart';

class NavBarItem {
  final IconData icon;
  final String title;
  final String routeName;
  final Map<String, dynamic> routeArguments;
  final List<String> inaccessibleRoutes;

  const NavBarItem({
    required this.icon,
    required this.title,
    required this.routeName,
    this.routeArguments = const {},
    this.inaccessibleRoutes = const []
  });
}
