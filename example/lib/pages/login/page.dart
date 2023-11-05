import 'package:flongo_client/pages/api_page.dart';
import 'package:flongo_client/utilities/http_client.dart';
import 'package:flongo_client/utilities/transitions/fade_to_black_transition.dart';
import 'package:flongo_client/widgets/navbar/app_navbar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../navbar.dart';
import '../../theme.dart';

class LoginPage extends API_Page {
  @override
  final String apiURL = '/authenticate';
  @override
  final AppNavBar navbar = NavBar();

  final String homeURL;

  LoginPage({super.key, this.homeURL='/home'});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends API_PageState<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _logoAnimationController = AnimationController(vsync: this);
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _logoAnimationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginSuccess() {
    _logoAnimationController.forward().then((_) {
      Navigator.pushNamed(
        context,
        widget.homeURL,
        arguments: {"_animation": FadeToBlackTransition.transitionsBuilder, "_animation_duration": 600}
      );
    });
  }

  @override
  Widget getPageWidget(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: MediaQuery.of(context).size.width * 0.1),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16.0),
              ],
              const SizedBox(height: 16.0),
              Lottie.asset(
                'assets/images/logo_animation.json',
                controller: _logoAnimationController,
                height: 240, 
                width: 240,
                animate: false,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value!.isEmpty ? 'Username required' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Password required' : null,
              ),
              const SizedBox(height: 50.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    HTTPClient('/authenticate').login(
                      _usernameController.text,
                      _passwordController.text,
                      (response) => _onLoginSuccess(),
                      (response) => setState(() {
                        _errorMessage = 'Failed to authenticate: ${response.body}';
                      })
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentTextColor,
                  minimumSize: const Size(200, 65)
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
  }
}
