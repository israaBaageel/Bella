import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/components/my_button.dart';
import 'package:test/components/textfield.dart';

class SignUp extends StatelessWidget {
  final void Function()? onTap;

  SignUp({super.key, required this.onTap});

  //text controllers
  TextEditingController userController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(height: 50,),

                  // greeting
                  SizedBox(height: 50),
                  //
                  Row(
                    children: [
                      Text(
                        'Sign up',
                        style: GoogleFonts.aboreto(
                          textStyle: TextStyle(fontSize: 25),
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
                          'Already have an account?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        GestureDetector(
                          onTap: onTap,

                          child: const Text(
                            ' Sign in here',
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

                  // user field
                  MyTextField(
                    hintText: "Enter your Email",
                    obscureText: false,
                    controller: userController,
                  ),

                  SizedBox(height: 10),

                  // email field
                  MyTextField(
                    hintText: "Enter your Email",
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

                  SizedBox(height: 10),

                  //  confirm password field
                  MyTextField(
                    hintText: "Confirm your Password",
                    obscureText: true,
                    controller: confirmpassController,
                  ),

                  SizedBox(height: 50),

                  //sign in button
                  MyButton(text: "Sign up", onTap: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
