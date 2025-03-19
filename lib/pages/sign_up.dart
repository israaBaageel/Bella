import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/components/my_button.dart';
import 'package:test/components/textfield.dart';
import 'package:test/pages/homePage.dart';

// ignore: must_be_immutable
class SignUp extends StatelessWidget {
  final void Function()? onTap;

  SignUp({super.key, required this.onTap});

  //text controllers
  TextEditingController userController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();

  final FirebaseAuth instance = FirebaseAuth.instance; // server auth db

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

                  const SizedBox(height: 50),
                  //
                  Row(
                    children: [
                      Text(
                        'Sign up',
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

                  const SizedBox(height: 50),

                  // user field
                  MyTextField(
                    hintText: "Enter your Email",
                    obscureText: false,
                    controller: userController,
                  ),

                  const SizedBox(height: 10),

                  // email field
                  MyTextField(
                    hintText: "Enter your Email",
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

                  const SizedBox(height: 10),

                  //  confirm password field
                  MyTextField(
                    hintText: "Confirm your Password",
                    obscureText: true,
                    controller: confirmpassController,
                  ),

                  const SizedBox(height: 50),

                  //sign in button

                  MyButton(
                    text: "Sign up",
                    onTap: () async {
                      try {
                        UserCredential credential =
                            await instance.createUserWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text);
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomePage(),),);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          //show snackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Make your password more strong')),
                          );
                        } else if (e.code == 'email-already-in-use') {
                          //show snackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email is already exist')),
                          );
                        }
                        //print('exception');
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
