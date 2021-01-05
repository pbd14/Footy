import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/constants.dart';

class CardW extends StatefulWidget {
  double height, width;
  Widget child;
  CardW({Key key, this.height, this.width, this.child}) : super(key: key);
  @override
  _CardWState createState() => _CardWState();
}

class _CardWState extends State<CardW> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * widget.height,
      width: size.width * widget.width,
      child: Card(
        color: whiteColor,
        shadowColor: darkPrimaryColor,
        elevation: 7,
        child: widget.child,
      ),
    );
  }
}
