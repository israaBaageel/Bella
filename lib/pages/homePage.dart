import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:test/pages/messagePage.dart';
import 'package:test/pages/firstPage.dart';
import 'package:test/pages/profile.dart';
import 'package:test/pages/donation_screen.dart';
import 'package:test/pages/upload_page.dart';
import 'package:test/pages/outfit_generator_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomePage> {
  // navigation around the bottom bar
  int _selectedIndex = 0;
  void _navigateBottomNavBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // pages to navigate to
  final List<Widget> _children = [
    Center(child: Firstpage()),
    Center(child: OutfitGeneratorPage()),
    Center(child: Center(child: UploadPage())),
    Center(child: MessagePage()),
    Center(child: DonationScreen(selectedItems: [])),
    Center(child: Profile()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_selectedIndex],
      bottomNavigationBar: StylishBottomBar(
        option: BubbleBarOptions(
          barStyle: BubbleBarStyle.horizontal,
          bubbleFillStyle: BubbleFillStyle.fill,
          opacity: 0.4,
        ),
        items: [
          BottomBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            backgroundColor: Colors.pink,
          ),
          BottomBarItem(
            icon: Icon(Icons.calendar_month),
            title: Text('Calendar'),
            backgroundColor: Colors.green,
          ),
          BottomBarItem(
            icon: Icon(Icons.add_a_photo),
            title: Text('Add'),
            backgroundColor: Colors.orange,
          ),
          BottomBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            title: Text('Chat'),
            backgroundColor: Colors.purple,
          ),
          BottomBarItem(
            icon: Icon(Icons.favorite),
            title: Text('Donate'),
            backgroundColor: Colors.red,
          ),
          BottomBarItem(
            icon: Icon(Icons.account_circle_outlined),
            title: Text('Profile'),
            backgroundColor: Colors.teal,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _navigateBottomNavBar,
      ),
    );
  }
}
