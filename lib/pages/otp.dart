import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/components/my_button.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:test/pages/confirm.dart';



class Otp extends StatelessWidget{

  Otp({super.key}); 

  @override
  Widget build(BuildContext context){
    return  Scaffold(
      appBar: AppBar(
        
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 

                // greeting 
                Row(
                  children: [
                    Text(
                      'Verification Code',
                    style: GoogleFonts.aboreto(
                      textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold ),
                                  
                    ), 
                    ),
                  ],
                ),
                SizedBox(height: 50), 
                //
                Text(
                  'We have sent the verification code ',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(fontSize: 18,color: Colors.grey),
                
                    ),
                  ),
                  Text(
                    'to your email address',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),

                  //


                  SizedBox(height: 50),
OtpTextField(
        numberOfFields: 5,
        borderColor: Color(0xFF512DA8),
        //set to true to show as box or false to show as dash
        showFieldAsBox: true, 
        //runs when a code is typed in
        onCodeChanged: (String code) {
            //handle validation or checks here           
        },
        //runs when every textfield is filled
        onSubmit: (String verificationCode){
            showDialog(
                context: context,
                builder: (context){
                return AlertDialog(
                    title: Text("Verification Code"),
                    content: Text('Code entered is $verificationCode'),
                );
                }
            );
        }, // end onSubmit
    ),
              
              SizedBox(height: 50),
              
                //sign in button 
                
                MyButton(text: "Confirm", onTap: (){
                    
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => confirm()),
                      );
                },
                )
              
              
              ],
              
              ),
            ),
          ),
        ),
      ),
    );
  }
}