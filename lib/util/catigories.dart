import 'package:flutter/material.dart';
import 'package:test/util/bubble_cat.dart';

class Catigories extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const Catigories({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      'Top',
      'Bottom',
      'Shoes',
      'Dress',
      'Others',
    ];

    final images = {
      'All': 'lib/images/image1.jpg',
      'Top': 'lib/images/top.jpg',
      'Bottom': 'lib/images/bottom.jpg',
      'Shoes': 'lib/images/image1.jpg',
      'Dress': 'lib/images/dress.jpg',
      'Others': 'lib/images/image6.jpg',
    };

    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((cat) {
          return BubbleCat(
            text: cat,
            image: images[cat]!,
            isSelected: selectedCategory == cat,
            onTap: () => onCategorySelected(cat),
          );
        }).toList(),
      ),
    );
  }
}
