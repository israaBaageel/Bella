import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({super.key});

  @override
  State<ImageSlider> createState() => _ImageAutoSliderState();
}

class _ImageAutoSliderState extends State<ImageSlider> {
  /// HERE WE CREATE LIST OF IMAGE
  List<Image> imageList = [
    Image.asset("lib/images/Awon.jpg", width: 200,),
    Image.asset("lib/images/image3.jpg"),
    Image.asset("lib/images/image4.jpg"),
    Image.asset("lib/images/image5.jpg"),
    Image.asset("lib/images/image2.jpg"),
    Image.asset("lib/images/image6.jpg"),
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return 

       Column(
        children: [
          /// here we apply
          CarouselSlider.builder(
              itemCount: imageList.length,
              itemBuilder: (context, index, realIndex) {
                return imageList[index];
              },
              options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 10,
                  viewportFraction: 0.8,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  })),

          /// here we show inductor
          Row(
            
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(imageList.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 12.0,
                width: currentIndex == index ? 24 : 12,
                decoration: BoxDecoration(
                  color: currentIndex == index ? Color(0xffFFA3BE) : Colors.black54,
                  borderRadius: BorderRadius.circular(6.8),
                ),
              );
            }),
          )
        ],
      );
    
  }
}
