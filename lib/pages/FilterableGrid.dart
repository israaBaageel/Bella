import 'package:flutter/material.dart';
import 'package:test/pages/profile.dart';
import 'package:test/util/catigories.dart';

class FilterableGrid extends StatefulWidget {
  const FilterableGrid({super.key});

  @override
  State<FilterableGrid> createState() => _FilterableGridState();
}

class _FilterableGridState extends State<FilterableGrid> {//====================
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Catigories(
          selectedCategory: selectedCategory,
          onCategorySelected: (newCat) {
            setState(() {
              selectedCategory = newCat;
            });
          },
        ),
        Expanded(
          child: AllItemGrid(
            categoryFilter: selectedCategory,
          ),
        ),
      ],
    );
  }
}
