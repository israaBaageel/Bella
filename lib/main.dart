// ignore_for_file: unused_import

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:test/auth/login_or_signUp.dart';
import 'package:test/consts.dart';
import 'package:test/intro_screens/splash_screen.dart';

import 'package:test/pages/forgot_pass.dart';
import 'package:test/pages/gemchat.dart';
import 'package:test/pages/otp.dart';
import 'package:test/pages/homePage.dart';
import 'package:test/pages/profile.dart';
import 'package:test/pages/upload_page.dart';
import 'package:test/theme/dark_mode.dart';
import 'package:test/theme/light_mode.dart';
import 'package:test/utils.dart';

void main() async {
  Gemini.init(apiKey: "AIzaSyCbUBtmrXm8sx-v0YaDZgjk2CFwMyWSc4k");
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
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
  await registerServices();

  ///----------------------------------
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      saveLocale: true,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: SplashScreen(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
