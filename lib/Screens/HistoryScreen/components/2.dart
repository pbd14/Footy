import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Booking.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/card.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  _bookings != null
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _bookings.length,
                          itemBuilder: (BuildContext context, int index) =>
                              CardW(
                            width: 0.8,
                            ph: 170,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            children: [
                                              Text(
                                                DateFormat.yMMMd()
                                                    .format(
                                                        Booking.fromSnapshot(
                                                                _bookings[
                                                                    index])
                                                            .timestamp_date
                                                            .toDate())
                                                    .toString(),
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                Booking.fromSnapshot(
                                                        _bookings[index])
                                                    .status,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: Booking.fromSnapshot(
                                                                    _bookings[
                                                                        index])
                                                                .status ==
                                                            'unfinished'
                                                        ? darkPrimaryColor
                                                        : Colors.red,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.2,
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            children: [
                                              Text(
                                                // _places != null
                                                //     ? _places[Booking.fromSnapshot(book)
                                                //                     .id]
                                                //                 .name !=
                                                //             null
                                                //         ? _places[Booking.fromSnapshot(
                                                //                     book)
                                                //                 .id]
                                                //             .name
                                                //         : 'Place'
                                                //     : 'Place',
                                                'Place',
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                Booking.fromSnapshot(
                                                            _bookings[index])
                                                        .from +
                                                    ' - ' +
                                                    Booking.fromSnapshot(
                                                            _bookings[index])
                                                        .to,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    RoundedButton(
                                      width: 0.3,
                                      height: 0.07,
                                      text: 'On Map',
                                      press: () {},
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
                                      press: () {},
                                      color: darkPrimaryColor,
                                      textColor: whiteColor,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          );
  }
}
