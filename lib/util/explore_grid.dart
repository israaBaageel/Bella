import 'package:flutter/material.dart';

class ExploreGrid extends StatelessWidget {
  const ExploreGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
     itemBuilder: (context, index) => Padding(
      padding: const EdgeInsets.all(2.0),
      child: Image.asset('lib/images/image${index +1}.jpg'),
      ),
 
     
     
     );
  }
}