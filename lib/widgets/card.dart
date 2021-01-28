import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/constants.dart';

// ignore: must_be_immutable
class CardW extends StatefulWidget {
  double height, width, pw, ph;
  Widget child;
  CardW({Key key, this.height, this.width, this.child, this.pw, this.ph})
      : super(key: key);
  @override
  _CardWState createState() => _CardWState();
}

class _CardWState extends State<CardW> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: widget.ph == null ? size.height * widget.height : widget.ph,
      width: widget.pw == null ? size.width * widget.width : widget.pw,
      child: Card(
        color: whiteColor,
        shadowColor: darkPrimaryColor,
        elevation: 7,
        child: widget.child,
      ),
    );
  }
}
