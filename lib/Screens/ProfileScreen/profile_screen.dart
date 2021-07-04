import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:google_fonts/google_fonts.dart';

import '../loading_screen.dart';
import 'components/1.dart';
import 'components/2.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                backgroundColor: darkColor,
                centerTitle: true,
                title: TabBar(
                  indicatorColor: primaryColor,
                  tabs: [
                    Tab(
                      child: Text(
                        'Favourites',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Activity',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  ProfileScreen2(),
                  ProfileScreen1(),
                ],
              ),
            ),
          );
  }
}
