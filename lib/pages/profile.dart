import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:test/pages/All_itemPage.dart';
import 'package:test/util/bubble_cat.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/util/catigories.dart';
import 'package:test/util/explore_grid.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

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
        appBar: AppBar(),
        body: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sarah.k',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 50),

            // Tab Bar
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.star)),
                Tab(icon: Icon(Icons.wallet)),
                Tab(icon: Icon(Icons.auto_awesome_outlined)),
              ],
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text(
                    'MY CLOSET'.tr(),
                    style: GoogleFonts.aboreto(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Categories List
            Catigories(),

            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [Icon(Icons.tune)],
              ),
            ),

            // Pictures Grid
            const Expanded(child: ExploreGrid()),
          ],
        ),
      ),
    );
  }
}
