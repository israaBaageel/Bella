import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/components/my_button.dart';

import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class confirm extends StatelessWidget {
  const confirm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Success!',
                        style: GoogleFonts.aboreto(
                          textStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  //
                  Text(
                    'Congratulations! You have been ',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                  Text(
                    'successfully authenticated',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),

                  //
                  SizedBox(height: 50),

                  SizedBox(height: 50),

                  //sign in button
                  MyButton(text: "Confirm", onTap: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
