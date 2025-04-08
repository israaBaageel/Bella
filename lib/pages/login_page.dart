import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/components/my_button.dart';
import 'package:test/components/textfield.dart';
import 'package:test/pages/forgot_pass.dart';
import 'package:test/pages/homePage.dart';
import 'package:test/services/auth_service.dart';

// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

  class _LoginPageState extends State<LoginPage> {
  //text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth instance = FirebaseAuth.instance; // server auth db
  var loginKey = GlobalKey<ScaffoldState>();
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;

    @override
  void initState() {
    super.initState();

    _authService = _getIt.get<AuthService>();
 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: loginKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),

                  // greeting
                  Text(
                    'Welcome back you’ve been missed!',
                    style: GoogleFonts.aboreto(
                      textStyle: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  //
                  Row(
                    children: [
                      Text(
                        'Sign in',
                        style: GoogleFonts.aboreto(
                          textStyle: const TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  //
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Row(
                      children: [
                        const Text(
                          'New here?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        //////////////////////////////////////////////////////
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            ' Create an account',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // email field
                  MyTextField(
                    hintText: 'Enter your Email',
                    obscureText: false,
                    controller: emailController,
                  ),

                  const SizedBox(height: 10),

                  // password field
                  MyTextField(
                    hintText: "Enter your Password",
                    obscureText: true,
                    controller: passwordController,
                  ),

                  //forgot pass ?
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ForgotPass()),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 230.0),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  //sign in button

                  MyButton(
                    text: "Sign in",
                    onTap: () async {
                      try {
                        await _authService.login( emailController.text, passwordController.text);

                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomePage(),),);
                      } on FirebaseAuthException catch (e) {
                        print(e);
                        if (e.code == 'invalid-credential') {
                          ScaffoldMessenger.of(context).showSnackBar(////////////////////////////////
                            const SnackBar(content: Text('Invalid email or password')),
                          );
                        }
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
