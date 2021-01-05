import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Booking.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Screens/HomeScreen/home_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/card.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class History1 extends StatefulWidget {
  @override
  _History1State createState() => _History1State();
}

class _History1State extends State<History1> {
  bool loading = false;
  List _bookings;
  Map _places = {'test': 'test'};

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
          whereIn: ['unfinished', 'verification_needed'],
        )
        .where(
          'userId',
          isEqualTo: FirebaseAuth.instance.currentUser.uid,
        )
        .get();
    _bookings = data.docs;
    for (dynamic book in _bookings) {
      var data1 = await FirebaseFirestore.instance
          .collection('locations')
          .doc(Booking.fromSnapshot(book).placeId)
          .get();
      var data2 = Place.fromSnapshot(data1);
      _places.addAll({
        Booking.fromSnapshot(book).id: data2,
      });
    }

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
                    ? Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _bookings.length,
                          itemBuilder: (BuildContext context, int index) =>
                              CardW(
                            width: 0.8,
                            height: 0.45,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 15, 0),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: size.height * 0.04,
                                    ),
                                    Text(
                                      DateFormat.yMMMd()
                                          .format(Booking.fromSnapshot(
                                                  _bookings[index])
                                              .timestamp_date
                                              .toDate())
                                          .toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      Booking.fromSnapshot(_bookings[index])
                                              .from +
                                          ' - ' +
                                          Booking.fromSnapshot(_bookings[index])
                                              .to,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _places != null
                                          ? _places[Booking.fromSnapshot(
                                                      _bookings[index])
                                                  .id]
                                              .name
                                          : 'Place',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        Booking.fromSnapshot(_bookings[index])
                                                    .info !=
                                                null
                                            ? Booking.fromSnapshot(
                                                    _bookings[index])
                                                .info
                                            : 'No info',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkPrimaryColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      Booking.fromSnapshot(_bookings[index])
                                          .status,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: Booking.fromSnapshot(
                                                          _bookings[index])
                                                      .status ==
                                                  'unfinished'
                                              ? darkPrimaryColor
                                              : Colors.red,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                          height: size.height * 0.02,
                                        ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        RoundedButton(
                                          width: 0.3,
                                          height: 0.07,
                                          text: 'On Map',
                                          press: () async {
                                            setState(() {
                                              loading = true;
                                            });
                                            Navigator.push(
                                              context,
                                              SlideRightRoute(
                                                page: HomeScreen(
                                                  selected: 'map',
                                                  data: {
                                                    'lat': _places != null
                                                        ? _places[Booking.fromSnapshot(
                                                                    _bookings[
                                                                        index])
                                                                .id]
                                                            .lat
                                                        : null,
                                                    'lon': _places != null
                                                        ? _places[Booking.fromSnapshot(
                                                                    _bookings[
                                                                        index])
                                                                .id]
                                                            .lon
                                                        : null
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          color: darkPrimaryColor,
                                          textColor: whiteColor,
                                        ),
                                        SizedBox(
                                          width: size.width * 0.04,
                                        ),
                                        RoundedButton(
                                          width: 0.3,
                                          height: 0.07,
                                          text: 'Book',
                                          press: () async {},
                                          color: darkPrimaryColor,
                                          textColor: whiteColor,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height * 0.05,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: size.height * 0.15,
                ),
              ],
            ),
          );
  }
}
