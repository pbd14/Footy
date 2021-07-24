import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  final double width, height, pw, ph;
  const RoundedButton(
      {Key key,
      this.text,
      this.press,
      this.color,
      this.textColor,
      this.width,
      this.height,
      this.pw,
      this.ph})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: pw == null ? size.width * width : pw,
      height: ph == null ? size.height * height : ph,
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.circular(29),
        shape: BoxShape.rectangle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: TextButton(
            onPressed: press,
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                color: textColor,
              )),
            ),
          ),
        ),
      ),
    );
  }
}
