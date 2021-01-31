import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/constants.dart';

class LabelButton extends StatefulWidget {
  const LabelButton(
      {Key key,
      this.color1,
      this.color2,
      this.ph,
      this.pw,
      this.size,
      this.onTap})
      : super(key: key);

  final Color color1;
  final Color color2;
  final double ph;
  final double pw;
  final double size;
  final Function onTap;

  @override
  _LabelButtonState createState() => _LabelButtonState();
}

class _LabelButtonState extends State<LabelButton> {
  bool isColored = false;
  Color labelColor;
  @override
  Widget build(BuildContext context) {
    if (labelColor == null) {
      labelColor = widget.color2;
    }
    return FlatButton(
      highlightColor: darkPrimaryColor,
      height: widget.ph,
      minWidth: widget.pw,
      onPressed: () {
        setState(() {
          isColored = !isColored;
          if (isColored) {
            labelColor = widget.color1;
          } else {
            labelColor = widget.color2;
          }
        });
        widget.onTap();
      },
      child: Icon(
        Icons.label,
        color: labelColor == null ? widget.color2 : labelColor,
        size: widget.size,
      ),
    );
  }
}
