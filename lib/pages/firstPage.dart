import 'package:flutter/material.dart';
import 'package:test/components/image_slider.dart';
import 'package:test/pages/All_itemPage.dart';
import 'package:test/util/bubble_cat.dart';
import 'package:google_fonts/google_fonts.dart';

class Firstpage extends StatelessWidget {
  const Firstpage({super.key});

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Hello, Gorgeousssssssssss!',
            style: GoogleFonts.aboreto(
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(10),
          children: [
            // Image Slider
            const ImageSlider(),

            const SizedBox(height: 30),

            // Categories Section
            Text(
              'Categories',
              style: GoogleFonts.aboreto(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Categories List
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  BubbleCat(
                    text: 'All',
                    image: 'lib/images/image1.jpg',
                    onTap: () => navigateTo(context, AllItemPage()),
                  ),
                  BubbleCat(
                    text: 'Top',
                    image: 'lib/images/top.jpg',
                    onTap: (){},
                  ),
                  BubbleCat(
                    text: 'Bottom',
                    image: 'lib/images/bottom.jpg',
                    onTap: (){},
                  ),
                  BubbleCat(
                    text: 'Shoes',
                    image: 'lib/images/image1.jpg',
                    onTap: (){},
                  ),
                  BubbleCat(
                    text: 'Dress',
                    image: 'lib/images/dress.jpg',
                    onTap: (){},
                  ),
                  BubbleCat(
                    text: 'Others',
                    image: 'lib/images/image6.jpg',
                    onTap: (){},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Charity Section
            Text(
              'Give Your Clothes A New Life',
              style: GoogleFonts.abhayaLibre(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Charity Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 209, 224),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade500,
                    offset: const Offset(4.0, 4.0),
                    blurRadius: 3.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Share your kindness',
                      style: GoogleFonts.aboreto(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Image.asset('lib/images/Awon.jpg', height: 120, width: 180),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
