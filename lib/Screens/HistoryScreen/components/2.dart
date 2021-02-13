import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Booking.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Screens/MapScreen/map_screen.dart';
import 'package:flutter_complete_guide/Screens/PlaceScreen/place_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/card.dart';
import 'package:flutter_complete_guide/widgets/label_button.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class History2 extends StatefulWidget {
  @override
  _History2State createState() => _History2State();
}

class _History2State extends State<History2> {
  bool loading = false;
  List _bookings;
  Map _places = {};

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
                                    Flexible(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          children: [
                                            Text(
                                              _places != null
                                                  ? _places[Booking.fromSnapshot(
                                                                      _bookings[
                                                                          index])
                                                                  .id]
                                                              .name !=
                                                          null
                                                      ? _places[Booking.fromSnapshot(
                                                                  _bookings[
                                                                      index])
                                                              .id]
                                                          .name
                                                      : 'Place'
                                                  : 'Place',
                                              overflow:
                                                  TextOverflow.ellipsis,
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
                                              overflow:
                                                  TextOverflow.ellipsis,
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
                                  press: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: MapScreen(
                                          data: {
                                            'lat': _places[
                                                Booking.fromSnapshot(
                                                        _bookings[index])
                                                    .id]
                                                .lat,
                                            'lon': _places[
                                                Booking.fromSnapshot(
                                                        _bookings[index])
                                                    .id]
                                                .lon
                                          },
                                        ),
                                      ),
                                    );
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                                  color: darkPrimaryColor,
                                  textColor: whiteColor,
                                ),
                                SizedBox(
                                  width: size.width * 0.04,
                                ),
                                _places != null
                                    ? LabelButton(
                                        isC: false,
                                        reverse: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(FirebaseAuth
                                                .instance.currentUser.uid),
                                        containsValue: _places[
                                                Booking.fromSnapshot(
                                                        _bookings[index])
                                                    .id]
                                            .id,
                                        color1: Colors.red,
                                        color2: lightPrimaryColor,
                                        ph: 45,
                                        pw: 45,
                                        size: 40,
                                        onTap: () {
                                          setState(() {
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(FirebaseAuth.instance
                                                    .currentUser.uid)
                                                .update({
                                              'favourites':
                                                  FieldValue.arrayUnion([
                                                _places[Booking
                                                            .fromSnapshot(
                                                                _bookings[
                                                                    index])
                                                        .id]
                                                    .id
                                              ])
                                            });
                                          });
                                        },
                                        onTap2: () {
                                          setState(() {
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(FirebaseAuth.instance
                                                    .currentUser.uid)
                                                .update({
                                              'favourites':
                                                  FieldValue.arrayRemove([
                                                _places[Booking
                                                            .fromSnapshot(
                                                                _bookings[
                                                                    index])
                                                        .id]
                                                    .id
                                              ])
                                            });
                                          });
                                        },
                                      )
                                    : Container(),
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
        );
  }
}
