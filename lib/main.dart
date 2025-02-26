import 'package:flutter/material.dart';
import 'package:test/auth/login_or_signUp.dart';
import 'package:test/pages/forgot_pass.dart';
import 'package:test/pages/otp.dart';
import 'package:test/pages/homePage.dart';
import 'package:test/pages/profile.dart';
import 'package:test/theme/dark_mode.dart';
import 'package:test/theme/light_mode.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home : HomePage(),
      theme: lightMode,
      darkTheme: darkMode,

    );
  }
}
