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
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: whiteColor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: size.width * 0.2,
                backgroundColor: primaryColor,
                centerTitle: true,
                title: TabBar(
                  indicatorColor: whiteColor,
                  tabs: [
                    Tab(
                      child: Text(
                        'Profile',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Favourites',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  ProfileScreen1();
                  ProfileScreen2();
                ],
              ),
            ),
          );
  }
}
