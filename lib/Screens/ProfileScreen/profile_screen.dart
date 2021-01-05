import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Screens/LoginScreen/login_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/Services/auth_service.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/Screens/ProfileScreen/components/background.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    '+998909032004',
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: darkPrimaryColor,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                RoundedButton(
                                  width: 0.3,
                                  height: 0.085,
                                  text: 'SIGN OUT',
                                  press: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    dynamic res = AuthService().signOut();
                                    if (res == null) {
                                      loading = false;
                                    } else {
                                      Navigator.push(
                                          context,
                                          SlideRightRoute(
                                            page: LoginScreen(),
                                          ));
                                    }
                                  },
                                  color: darkPrimaryColor,
                                  textColor: whiteColor,
                                ),
                              ]),
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
