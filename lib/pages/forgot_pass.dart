import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/components/my_button.dart';
import 'package:test/components/textfield.dart';
import 'package:test/pages/otp.dart';


class ForgotPass extends StatelessWidget{

 


  ForgotPass({super.key}); 

  //text controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();  

  @override
  Widget build(BuildContext context){
    return  Scaffold(
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
                      'Reset Password',
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
                      textStyle: TextStyle(fontSize: 18,color: Colors.grey),
                    
                    ),
                    ),  
                      //


                  SizedBox(height: 50),
              
              
                // email field 
                  MyTextField(
                    hintText: 'Enter new password',
                    obscureText: true,
                    controller: emailController,
                  ),
                                                                          Text(
                      '*Must be 8 or more characters and contain at least 1 number and 1 special character. ',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(fontSize: 13,color: Colors.grey),
                    
                    ),
                    ),
              
                SizedBox(height: 10),
              
                // password field 
                  MyTextField(
                    hintText: "confirm password",
                    obscureText: true,
                    controller: passwordController,
                  ),
              
              

              
              
              SizedBox(height: 50),
              
                //sign in button 
                
                MyButton(text: "Reset Password", onTap: (){   
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Otp()),
                      );},
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