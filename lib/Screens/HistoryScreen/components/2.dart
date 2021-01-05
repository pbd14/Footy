import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Booking.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/card.dart';
import 'package:google_fonts/google_fonts.dart';

class History2 extends StatefulWidget {
  @override
  _History2State createState() => _History2State();
}

class _History2State extends State<History2> {
  bool loading = false;
  List _bookings;

  Future<void> loadData() async {
    setState(() {
      loading = true;
    });
    var data = await FirebaseFirestore.instance
        .collection('bookings')
        .orderBy(
          'timestamp_date',
          descending: true,
        )
        .where(
          'status',
          isEqualTo: 'finished',
        )
        .where(
          'userId',
          isEqualTo: FirebaseAuth.instance.currentUser.uid,
        )
        .get();
    _bookings = data.docs;
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Container(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                _bookings != null
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: _bookings.length,
                        itemBuilder: (BuildContext context, int index) => CardW(
                          width: 0.1,
                          height: 0.3,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 15, 0),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: size.height * 0.04,
                                  ),
                                  Text(
                                    Booking.fromSnapshot(_bookings[index]).date,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: darkPrimaryColor,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          );
  }
}
