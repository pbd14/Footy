import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/Screens/SettingsScreen/components/background.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  String stext;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: whiteColor,
            body: SingleChildScrollView(
              child: Background(
                child: Form(
                  key: _formKey,
                  child: Container(
                    color: whiteColor,
                    width: size.width * 0.85,
                    height: size.height * 0.75,
                    margin: EdgeInsets.fromLTRB(size.width * 0.075,
                        size.height * 0, size.width * 0.075, size.height * 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(29),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              'Settings',
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: darkPrimaryColor,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
