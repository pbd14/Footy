import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class SomethingWentWrongScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: Text(
          'SOMETHING WENT WRONG',
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              color: primaryColor,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
