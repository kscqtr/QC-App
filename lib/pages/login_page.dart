import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'selection_page.dart'; // Import the SelectionPage

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Define the correct username and password.
  static const String _correctUsername = '2';
  static const String _correctPassword = '2';

  // Updated authentication function for login.
  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(const Duration(milliseconds: 1000)).then((_) {
      // Check if the username and password are correct.
      if (data.name != _correctUsername || data.password != _correctPassword) {
        return 'Wrong username or password';
      }
      // If correct, return null for success.
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      // The logo property displays an image asset.
      // Make sure 'images/keystone.png' is declared in your pubspec.yaml file.
      logo: const AssetImage('images/keystone.png'),
      // Add this theme property to change the background color.
      theme: LoginTheme(
        pageColorLight: Colors.white,
        pageColorDark: Colors.white,
        
      ),
      // This changes the hint text of the user input field to 'Username'.
      messages: LoginMessages(
        userHint: 'Username',
      ),
      
      disableCustomPageTransformer: true, // Disable custom page transformer for simplicity.
      // Provide custom validators to override the defaults.
      userValidator: (value) {
        if (value == null || value.isEmpty) {
          return 'Username cannot be empty';
        }
        return null;
      },
      passwordValidator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password cannot be empty';
        }
        return null;
      },
      onLogin: _authUser,
      // Use these boolean flags to explicitly hide the buttons.
      hideForgotPasswordButton: true,
      onRecoverPassword: (String name) {
        // This function is not used, but required by the Flutter Login package.
        return Future.value(null);
      },
      onSubmitAnimationCompleted: () {
        // After the animation completes, navigate to the selection page.
        // We use pushReplacement to prevent the user from going back to the login screen.
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const SelectionPage(),
        ));
      },
    );
  }
}
