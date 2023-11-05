import 'package:flongo_client/styles/theme.dart';
import 'package:flongo_client/utilities/http_client.dart';
import 'package:flongo_client/utilities/transitions/fade_to_black_transition.dart';
import 'package:flongo_client/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class BasePage extends StatefulWidget {
  final bool authenticationRequired = false;
  final AppNavBar navbar = AppNavBar();

  BasePage({super.key});
}

abstract class BasePageState<T extends BasePage> extends State<T> {
  static final env = dotenv.env;
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    if (widget.authenticationRequired && !HTTPClient.isAuthenticated()) {
      // TODO - Logging for unauthenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
    }
  }

  List<Widget> _buildStaticNavBarItems(BuildContext context) {
    return (widget.navbar.getNavbarItems()).map((item) {
      return ListTile(
        leading: Icon(item.icon),
        title: Text(item.title),
        onTap: () {
          if (![item.routeName, ...item.inaccessibleRoutes].contains(ModalRoute.of(context)?.settings.name)) {
            Navigator.of(context).pushReplacementNamed(
              item.routeName,
              arguments: item.routeArguments,
            );
          }
        },
      );
    }).toList();
  }

  @protected
  Widget getPageWidget(BuildContext context);

  @protected
  Widget getPageLoadingWidget(BuildContext context) => const CircularProgressIndicator();

  @protected
  Widget getPageErrorWidget(BuildContext context) => Text(error);

  @protected
  Widget _getPageWidget(BuildContext context) {
    if (isLoading) {
      return getPageLoadingWidget(context);
    }

    if (error.isNotEmpty) {
      return getPageErrorWidget(context);
    }

    return getPageWidget(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900], // Stylish dark color
        title: Text(
          env['APP_NAME'] ?? 'App Name',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: _buildAppBarActions(context),
      ),
      body: Center(child: _getPageWidget(context)),
      drawer: _buildNavBar(context),
      bottomNavigationBar: _buildFooter(),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    if (HTTPClient.isAuthenticated()) {
      return [
        const CircleAvatar(
          radius: 20,
        ),
        const SizedBox(width: 10),
      ];
    }
    return [];
  }

  Widget _buildNavBar(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(HTTPClient.getUsername() ?? 'Guest'),
            accountEmail: Text(HTTPClient.isAuthenticated() ? "Email: ${HTTPClient.getEmail() ?? 'None'}" : 'Please Login'),
            currentAccountPicture: const CircleAvatar(),
          ),
          ..._buildStaticNavBarItems(context),
          if (HTTPClient.isAdminAuthenticated()) ...[
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                HTTPClient('/authenticate').logout(
                (response) {
                  Navigator.pushNamed(
                    context, 
                    '/',
                    arguments: {"_animation": FadeToBlackTransition.transitionsBuilder, "_animation_duration": 800}
                  );
                },
                (response) {
                  Navigator.pushNamed(
                    context, 
                    '/',
                    arguments: {"_animation": FadeToBlackTransition.transitionsBuilder, "_animation_duration": 800}
                  );
                },
              );
              },
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFooter() {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600; // Define your breakpoint for smaller displays

    Widget footerContent = Wrap(
      alignment: isSmallScreen ? WrapAlignment.center : WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: _buildFooterChildren(),
    );

    return Container(
      padding: isSmallScreen ? const EdgeInsets.all(10) : const EdgeInsets.all(20),
      color: AppTheme.accentTextColor,
      child: footerContent,
    );
  }

  List<Widget> _buildFooterChildren() {
    return [
      Text(
        '© ${DateTime.now().year} ${env['APP_AUTHOR'] ?? 'Anonymous'}',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisSize: MainAxisSize.min, // Ensures the row takes minimum space required
        children: [
          TextButton(
            child: const Text('Terms of Service', style: TextStyle(color: Colors.white)),
            onPressed: () {},
          ),
          TextButton(
            child: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
            onPressed: () {},
          ),
        ],
      ),
    ];
  }

}
