import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatefulWidget {
  final Widget nwidget;
  LoadingScreen({Key key, this.nwidget}) : super(key: key);
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: whiteColor,
          child: Center(
            child: SpinKitFadingCube(
              color: primaryColor,
              size: 50.0,
            ),
          ),
        ),
      ),
    );
  }
}
