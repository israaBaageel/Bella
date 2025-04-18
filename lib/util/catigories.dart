import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:test/pages/All_itemPage.dart';
import 'package:test/util/bubble_cat.dart';

class Catigories extends StatelessWidget {
  const Catigories({super.key});
    void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return // Categories List
    SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          BubbleCat(
            text: 'All'.tr(),
            image: 'lib/images/image1.jpg',
            onTap: () => navigateTo(context, AllItemPage()),
          ),
          BubbleCat(
            text: 'Top'.tr(),
            image: 'lib/images/top.jpg',
            onTap: () {},
          ),
          BubbleCat(
            text: 'Bottom'.tr(),
            image: 'lib/images/bottom.jpg',
            onTap: () {},
          ),
          BubbleCat(
            text: 'Shoes'.tr(),
            image: 'lib/images/image1.jpg',
            onTap: () {},
          ),
          BubbleCat(
            text: 'Dress'.tr(),
            image: 'lib/images/dress.jpg',
            onTap: () {},
          ),
          BubbleCat(
            text: 'Others'.tr(),
            image: 'lib/images/image6.jpg',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
