import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  final double width, height;
  const RoundedButton({
    Key key, this.text, this.press, this.color, this.textColor, this.width, this.height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * width,
      height: size.height * height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
          child: FlatButton(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            color: color,
            onPressed: press, 
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  color: textColor,
                )
              ),
            ),
          ),
      ),
    );
  }
}