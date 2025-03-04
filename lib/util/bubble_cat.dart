import 'package:flutter/material.dart';

class BubbleCat extends StatelessWidget {
  final String text;
  final String image;

   BubbleCat({required this.text, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
               color: Colors.grey[300]),
               child: Image.asset(image, fit: BoxFit.cover,),
          ),
          SizedBox(height: 10,),
          Text(text),
          
        ],
      ),
    );
  }
}
