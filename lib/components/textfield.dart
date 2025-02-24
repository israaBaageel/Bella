import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget{
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,

  });
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
        cursorColor: Colors.grey[800],
  cursorWidth: 2.0,
      decoration : InputDecoration(
        filled: true,
        fillColor: Color(0xffF6E4EB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
// color outline of the field
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color.fromARGB(255, 233, 192, 192)),
        ),
// when field is clicked
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.pink),
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      obscureText: obscureText,
      
    );
  }


}