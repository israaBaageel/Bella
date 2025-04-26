import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Added
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/components/my_button.dart';
import 'package:test/components/textfield.dart';
import 'package:test/consts.dart';
import 'package:test/models/user_profile.dart';
import 'package:test/pages/homePage.dart';
import 'package:test/services/auth_service.dart';
import 'package:test/services/cloudinary_service.dart';
import 'package:test/services/database_service.dart';
import 'package:test/services/media_service.dart';

class SignUp extends StatefulWidget {
  final void Function()? onTap;

  const SignUp({super.key, required this.onTap});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();

  final FirebaseAuth instance = FirebaseAuth.instance;
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late MediaService _mediaService;
  late AppDatabaseService _databaseService;
  late CloudinaryService _cloudinaryService;

  File? selectedImage;
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _databaseService = _getIt.get<AppDatabaseService>();
    _authService = _getIt.get<AuthService>();
    _cloudinaryService = _getIt.get<CloudinaryService>();
  }

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
                  const SizedBox(height: 50),

                  Row(
                    children: [
                      Text(
                        'Sign up',
                        style: GoogleFonts.aboreto(
                          textStyle: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ],
                  ),

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
                          onTap: widget.onTap,
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

                  _pfpSelectionFiled(context),

                  const SizedBox(height: 50),

                  MyTextField(
                    hintText: "Enter your Name",
                    obscureText: false,
                    controller: userController,
                  ),

                  const SizedBox(height: 10),

                  MyTextField(
                    hintText: "Enter your Email",
                    obscureText: false,
                    controller: emailController,
                  ),

                  const SizedBox(height: 10),

                  MyTextField(
                    hintText: "Enter your Password",
                    obscureText: true,
                    controller: passwordController,
                  ),

                  const SizedBox(height: 10),

                  MyTextField(
                    hintText: "Confirm your Password",
                    obscureText: true,
                    controller: confirmpassController,
                  ),

                  const SizedBox(height: 50),

                  if (isloading)
                    Center(child: CircularProgressIndicator())
                  else
                    MyButton(text: "Sign up", onTap: _signUpUser),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUpUser() async {
    if (userController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    if (passwordController.text != confirmpassController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => isloading = true);

    try {
      await _authService.signup(emailController.text, passwordController.text);

      String? pfpURL;

      if (selectedImage != null) {
        final uploadResult = await _cloudinaryService.uploadProfileImage(
          selectedImage!,
          _authService.user!.uid,
        );
        if (uploadResult == null) {
          throw Exception("Profile picture upload failed");
        }
        pfpURL = uploadResult;
      }

      await _authService.user!.updateProfile(displayName: userController.text);

      // ✅ Save User to Firestore here
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_authService.user!.uid)
          .set({
            'email': emailController.text,
            'name': userController.text,
            'createdAt': Timestamp.now(),
            'pfpURL': pfpURL ?? PLACEHOLDER_PFP,
          });

      await _databaseService.createUserProfile(
        userProfile: UserProfile(
          uid: _authService.user!.uid,
          name: userController.text,
          email: emailController.text,
          pfpURL: pfpURL,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Sign up failed';
      if (e.code == 'weak-password') {
        errorMessage = 'Make your password more strong';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email already exists';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isloading = false);
    }
  }

  Widget _pfpSelectionFiled(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          final file = await _mediaService.getImageFromGallery();
          if (file != null) {
            setState(() => selectedImage = file);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to select image: ${e.toString()}")),
          );
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage:
            selectedImage != null
                ? FileImage(selectedImage!)
                : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }
}
