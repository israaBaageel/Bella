import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';


class IntroPage2 extends StatefulWidget {
  const IntroPage2({super.key});

  @override
  State<IntroPage2> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<IntroPage2> {
  @override
  Widget build(BuildContext context) {
    return Container(
            color: Colors.blue[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: 
                LottieBuilder.asset('assets/animations/box.json',repeat: true,
                width: 200,
                height: 200,)),
                SizedBox(height: 50,),

                Text(
            'Donation for your clothes ',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            
              ),
                      )

              ],
            ),
          );
  }
}