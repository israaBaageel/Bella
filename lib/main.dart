import 'package:flutter/material.dart';
import 'package:login_f/auth/login_or_signUp.dart';
import 'package:login_f/theme/dark_mode.dart';
import 'package:login_f/theme/light_mode.dart';
import 'package:firebase_core/firebase_core.dart';

main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home : LoginOrSignUp(), //Home(),
      theme: lightMode,
      darkTheme: darkMode,

    );
  }
}
