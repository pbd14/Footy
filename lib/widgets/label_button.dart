import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/constants.dart';

class LabelButton extends StatefulWidget {
  const LabelButton({
    Key key,
    this.color1,
    this.color2,
    this.ph,
    this.pw,
    this.size,
    this.onTap,
    this.onTap2,
    this.reverse,
    this.containsValue,
  }) : super(key: key);

  final Color color1;
  final Color color2;
  final double ph;
  final double pw;
  final double size;
  final Function onTap, onTap2;
  final DocumentReference reverse;
  final String containsValue;

  @override
  _LabelButtonState createState() => _LabelButtonState();
}

class _LabelButtonState extends State<LabelButton> {
  bool isColored = false;
  bool isOne = true;
  Color labelColor;
  StreamSubscription<DocumentSnapshot> subscription;
  List res = [];

  @override
  void initState() {
    super.initState();
    subscription = widget.reverse.snapshots().listen((docsnap) {
      if (docsnap.data()['favourites'].contains(widget.containsValue)) {
        setState(() {
          isColored = true;
        });
        print('DATA IS ALREADY HERE \n');
      } else if (!docsnap.data()['favourites'].contains(widget.containsValue)) {
        setState(() {
          print('NO DATA');
          print(docsnap.data()['favourites']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (labelColor == null) {
      labelColor = widget.color2;
    }
    if (isColored) {
      labelColor = widget.color1;
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
        isOne ? widget.onTap() : widget.onTap2();
        isOne = !isOne;
      },
      child: Icon(
        Icons.label,
        color: labelColor == null ? widget.color2 : labelColor,
        size: widget.size,
      ),
    );
  }
}
