import 'package:flongo_client/widgets/navbar/nav_bar_item.dart';

class AppNavBar {
  final List<NavBarItem> navbarItems;

  // Defining a const constructor
  const AppNavBar({this.navbarItems = const []});

  List<NavBarItem> getNavbarItems() => navbarItems;
}