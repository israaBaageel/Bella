import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test/pages/login_page.dart';
import 'package:test/pages/sign_up.dart';

class LoginOrSignUp extends StatefulWidget {
  const LoginOrSignUp({super.key});

  @override
  State<LoginOrSignUp> createState() => _LoginOrSignUpState();
}

class _LoginOrSignUpState extends State<LoginOrSignUp> {
  final FirebaseAuth instance = FirebaseAuth.instance; // server auth db
  bool showLoginPage = true;

  @override
  void initState() {
    super.initState();
    instance.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          showLoginPage = true; // Show login page when user is not authenticated
        });
      } else {
        // User is logged in, you can navigate to another screen if needed
      }
    });
  }

  // Toggle between login and sign-up pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLoginPage 
      ? LoginPage(onTap: togglePages)
      : SignUp(onTap: togglePages);
  }
}
