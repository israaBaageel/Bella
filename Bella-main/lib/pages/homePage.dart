import 'package:flutter/material.dart';
import 'package:test/pages/firstPage.dart';
import 'package:test/pages/profile.dart';
import 'package:test/pages/donation_screen.dart'; // Import the DonationScreen

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

  // pages to navigate to ///
  final List<Widget> _children = [
    Center(child: Firstpage()),
    Center(child: Text('ssss')),
    Center(child: Text('aaaa')),
    Center(child: Text('aoo')),
    Center(child: DonationScreen(selectedItems: [])), // Donation Screen
    Center(child: Profile()),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomNavBar,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add_a_photo), label: 'add'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Donate',
          ), // Donation icon
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'profile',
          ),
        ],
      ),
    );
  }
}
