import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Screens/HistoryScreen/components/1.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/2.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

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
                        'Upcoming',
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
                        'History',
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
                  History1(),
                  History2(),
                ],
              ),
            ),
          );
  }
}
