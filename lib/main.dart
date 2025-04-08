// ignore_for_file: unused_import

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/auth/login_or_signUp.dart';
import 'package:test/pages/forgot_pass.dart';
import 'package:test/pages/otp.dart';
import 'package:test/pages/homePage.dart';
import 'package:test/pages/profile.dart';
import 'package:test/theme/dark_mode.dart';
import 'package:test/theme/light_mode.dart';
import 'package:test/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCxMg3oUQ2hlFWV8NYq8PwTnUSl7epEhJY",
      appId: "1:995085343627:android:9f90e3fff63b1e1aefad8e",
      messagingSenderId: "995085343627",
      projectId: "outfit-6a1de",
    ),
  );
  await dotenv.load(fileName: ".env");
  await registerServices();///----------------------------------
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginOrSignUp(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
