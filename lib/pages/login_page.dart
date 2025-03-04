import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login_f/components/my_button.dart';
import 'package:login_f/components/textfield.dart';
import 'package:login_f/pages/forgot_pass.dart';
import 'package:login_f/pages/homePage.dart';

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  //text controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth instance = FirebaseAuth.instance; // server auth db
  var loginKey = GlobalKey<ScaffoldState>();

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
                  SizedBox(
                    height: 20,
                  ),

                  // greeting
                  Text(
                    'Welcome back you’ve been missed!',
                    style: GoogleFonts.aboreto(
                      textStyle: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  //
                  Row(
                    children: [
                      Text(
                        'Sign in',
                        style: GoogleFonts.aboreto(
                          textStyle: TextStyle(
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
                        Text(
                          'New here?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        //////////////////////////////////////////////////////
                        GestureDetector(
                          onTap: onTap,
                          child: const Text(
                            ' Create an acccount',
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

                  SizedBox(height: 50),

                  // email field
                  MyTextField(
                    hintText: 'Enter your Email',
                    obscureText: false,
                    controller: emailController,
                  ),

                  SizedBox(height: 10),

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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 230.0),
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

                  SizedBox(height: 50),

                  //sign in button

                  MyButton(
                    text: "Sign in",
                    onTap: () async {
                      try {
                        UserCredential credential =
                            await instance.signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage(),),);
                      } on FirebaseAuthException catch (e) {
                        print(e);
                        if (e.code == 'invalid-credential') {
                          ScaffoldMessenger.of(context).showSnackBar(////////////////////////////////
                            SnackBar(content: Text('Invalid email or password')),
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
