
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restart_app/restart_app.dart';

class ChangeLanguageView extends StatelessWidget {
  const ChangeLanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green[100],
          title: Text(
            'change Language',
            style: GoogleFonts.aboreto(
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 30,),
          ListTile(
            leading: Icon(Icons.star),
            title: Text(
              'العربية',
              style: GoogleFonts.aboreto(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () {
              //context.setLocale(Locale("ar"));
              Restart.restartApp();
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text(
              'English',
              style: GoogleFonts.aboreto(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () {
              //context.setLocale(Locale("en"));
              Restart.restartApp();
            },
          ),
        ],
        ),



    );
  }
}