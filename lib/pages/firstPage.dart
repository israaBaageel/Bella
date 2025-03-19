import 'package:flutter/material.dart';
import 'package:test/components/image_slider.dart';
import 'package:test/util/bubble_cat.dart';
import 'package:google_fonts/google_fonts.dart';

class Firstpage extends StatelessWidget {
  const Firstpage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Hello, Gorgiousssssssssss!',
            style: GoogleFonts.aboreto(
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: [
            //slider
            ImageSlider(),

            //tab bar//
            SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text(
                    'Catigories',
                    style: GoogleFonts.aboreto(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            //catigories
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  BubbleCat(text: 'All', image: 'lib/images/image1.jpg'),
                  BubbleCat(text: ' Top', image: 'lib/images/top.jpg'),
                  BubbleCat(text: 'Bottom', image: 'lib/images/bottom.jpg'),
                  BubbleCat(text: 'Shoes', image: 'lib/images/image1.jpg'),
                  BubbleCat(text: 'Dress', image: 'lib/images/dress.jpg'),
                  BubbleCat(text: 'Dress', image: 'lib/images/image6.jpg'),
                ],
              ),
            ),

            // charity
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text(
                    'Give Your Clothes A New Life',
                    style: GoogleFonts.abhayaLibre(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),

            //
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 209, 224),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade500,
                    offset: Offset(4.0, 4.0),
                    blurRadius: 3.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 15),

              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          'Share your\n kindness',
                          style: GoogleFonts.aboreto(
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 30),
                    Image.asset('lib/images/Awon.jpg', height: 120, width: 180),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [],
              ),
            ),

            //pictures
          ],
        ),
      ),
    );
  }
}
