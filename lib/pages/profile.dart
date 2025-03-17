import 'package:flutter/material.dart';
import 'package:test/util/bubble_cat.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/util/explore_grid.dart';


class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, size: 50, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text('Sarah.k', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 50),

            //tab bar//
      TabBar(tabs: [
        Tab(
          icon: Icon(Icons.star),
        ),
        Tab(
          icon: Icon(Icons.wallet),
        ),
        Tab(
          icon: Icon(Icons.auto_awesome_outlined),
        ),        

        ],
        ),
            SizedBox(height: 30),                    
      
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text('MY CLOSET', style: GoogleFonts.aboreto(
                    textStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),
      
                  ),),
                ],
              ),
            ),
            SizedBox(height: 10),
      
      
          //catigories
          Container(
            height: 140,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                BubbleCat(text: 'All', image: 'lib/images/image1.jpg',),
                BubbleCat(text: ' Top',image: 'lib/images/top.jpg'),
                BubbleCat(text: 'Bottom',image: 'lib/images/bottom.jpg'),
                BubbleCat(text: 'Shoes',image: 'lib/images/image1.jpg'),
                BubbleCat(text: 'Dress',image: 'lib/images/dress.jpg'),
                BubbleCat(text: 'Dress',image: 'lib/images/image6.jpg'),
                
            
            
              ],
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.tune),
              ],
            ),
          ),

          //pictures 
          Expanded(child: ExploreGrid()),
      

      
      
          ],
        ),
      ),
    );
  }
}