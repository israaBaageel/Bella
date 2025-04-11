import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
            color: Colors.yellow[100],
            child: Center(child:  LottieBuilder.asset('assets/animations/girl.json',repeat: true,)),
          );
  }
}