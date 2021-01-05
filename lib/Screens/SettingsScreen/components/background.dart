import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants.dart';

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
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  'assets/images/login_left_top.png',
                  width: 1.2 * size.width,
                )),
            Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset(
                'assets/images/login_right_bottom.png',
                width: 0.6 * size.width,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Settings',
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
          ],
        ));
  }
}
