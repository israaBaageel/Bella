import 'package:flutter/material.dart';

class BubbleCat extends StatelessWidget {
  final String text;
  final String image;

  const BubbleCat({super.key, required this.text, required this.image});

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
              // border: Border.all(color: Colors.white70),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade500,
                  offset: Offset(4.0, 4.0),
                  blurRadius: 2.0,
                  spreadRadius: 2.0,
                ),
              ],
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                width: 60,
                height: 60,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(text),
        ],
      ),
    );
  }
}
