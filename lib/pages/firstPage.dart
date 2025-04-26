
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:test/components/image_slider.dart';
import 'package:test/pages/All_itemPage.dart';
import 'package:test/pages/change_language_view.dart';
import 'package:test/pages/gemchat.dart';
import 'package:test/util/bubble_cat.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/util/catigories.dart';

class Firstpage extends StatelessWidget {
  const Firstpage({super.key});
  

/*   void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  } */

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          
          backgroundColor: Colors.green[100],
          title: Text(
            'Hello, Gorgeousss!'.tr(),
            style: GoogleFonts.aboreto(
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green[100],
                ),
                child: Text(
                  'Menu'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ///
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'.tr()),
                onTap: () {
                  // Update the UI
                 // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ChangeLanguageView()));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'.tr()),
                onTap: () {
                  // Update the UI
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Help'.tr()),
                onTap: () {
                  // Update the UI
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Gemchat()));
                },
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Language'.tr()),
                onTap: () {
                  
                 Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ChangeLanguageView()));
                
                },
              ),



               Divider(color: Colors.grey[200],),
               ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout'.tr(), style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Add your logout logic here
                 // _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),

        body: ListView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(10),
          children: [
            // Image Slider
              Container(
                color: Colors.yellow[200],
                child: ListTile(
                  leading: Icon(Icons.tips_and_updates),
                  title: Text('CLICK to get Fashion Assistant'.tr()),
                  onTap: () {
                    // Update the UI
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Gemchat()));
                  },
                ),
              ),
            const ImageSlider(),

            const SizedBox(height: 30),

            // Categories Section
            Text(
              'Categories'.tr(),
              style: GoogleFonts.aboreto(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Categories List
          //  Catigories(),

            const SizedBox(height: 20),

            // Charity Section
            Text(
              'Give Your Clothes A New Life'.tr(),
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
                      'Share your kindness'.tr(),
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
