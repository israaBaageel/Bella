import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:test/auth/login_or_signUp.dart';
import 'package:test/intro_screens/intro_page_1.dart';
import 'package:test/intro_screens/intro_page_2.dart';
import 'package:test/intro_screens/intro_page_3.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Intro> {
//controller track page
PageController _controller = PageController();

//track if on last page
bool onLastPage = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              IntroPage1(),
               IntroPage2(),
                IntroPage3()],
          ),

          // dot indicator
          Container(
            alignment: Alignment(0, 0.75),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            //skip
            GestureDetector(
              onTap: () {
              _controller.jumpToPage(2);
              },
              child: Text('skip')
              ),

            //dot indicator
            SmoothPageIndicator(controller: _controller, count: 3),

            //next or done
            onLastPage?
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return LoginOrSignUp();
                },),);
              },
              child: Text('done')
              ):            GestureDetector(
              onTap: () {
                _controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
              },
              child: Text('next')
              ),
          ],
        )),
        ],
      ),
    );
  }
} 