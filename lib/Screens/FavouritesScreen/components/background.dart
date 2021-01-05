import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Favourites',
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                color: whiteColor,
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          child,
        ],
      ),
      color: primaryColor,
    );
  }
}
