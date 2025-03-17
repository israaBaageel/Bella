import 'package:flutter/material.dart';
import 'package:test/pages/login_page.dart';
import 'package:test/pages/sign_up.dart';

class LoginOrSignUp extends StatefulWidget {
  const LoginOrSignUp({super.key});

  @override
  State<LoginOrSignUp> createState() => _LoginOrSignUpState();
}

class _LoginOrSignUpState extends State<LoginOrSignUp> {

// initially show login page 
bool showLoginPage = true;

//toggle between login and signUp
void togglePages(){
  setState(() {
    showLoginPage = !showLoginPage;
  });

}


  @override
  Widget build(BuildContext context) {
      if (showLoginPage){ 
        return LoginPage (onTap: togglePages);
  }else {
    return SignUp (onTap: togglePages);
  }
}
}

