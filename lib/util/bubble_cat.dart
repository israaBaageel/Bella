import 'package:flutter/material.dart';

class BubbleCat extends StatelessWidget {
  final String text;
  final String image;
  final VoidCallback onTap; // Added onTap function

  const BubbleCat({
    super.key,
    required this.text,
    required this.image,
    required this.onTap, // Require onTap function
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Trigger function when tapped
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade500,
                    offset: const Offset(4.0, 4.0),
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
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image, size: 30, color: Colors.grey);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(text),
          ],
        ),
      ),
    );
  }
}
