import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Booking.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Models/PushNotificationMessage.dart';
import 'package:flutter_complete_guide/Screens/MapScreen/map_screen.dart';
import 'package:flutter_complete_guide/Screens/OnEventScreen/on_event_screen.dart';
import 'package:flutter_complete_guide/Screens/PlaceScreen/place_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/card.dart';
import 'package:flutter_complete_guide/widgets/label_button.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../sww_screen.dart';

class History1 extends StatefulWidget {
  @override
  _History1State createState() => _History1State();
}

class _History1State extends State<History1> {
  bool loading = true;
  bool error = true;
  List _bookings;
  Map _places = {};
  Map placesSlivers = {};
  Map unrplacesSlivers = {};
  List _bookings1 = [];
  List _unrbookings1 = [];
  List slivers = [];
  List unratedBooks = [];
  List<Widget> sliversList = [];

  Future<void> loadData() async {
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
        .get()
        .catchError((error) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: 'Fail',
            body: 'Failed to get data',
          );
          showSimpleNotification(
            Container(child: Text(notification.body)),
            position: NotificationPosition.top,
            background: Colors.red,
          );
          if (this.mounted) {
            setState(() {
              loading = false;
              error = true;
            });
          } else {
            loading = false;
            error = true;
          }
        });
    _bookings = data.docs;
    for (dynamic book in _bookings) {
      var data1 = await FirebaseFirestore.instance
          .collection('locations')
          .doc(Booking.fromSnapshot(book).placeId)
          .get()
          .catchError((error) {
        PushNotificationMessage notification = PushNotificationMessage(
          title: 'Fail',
          body: 'Failed to get data',
        );
        showSimpleNotification(
          Container(child: Text(notification.body)),
          position: NotificationPosition.top,
          background: Colors.red,
        );
        if (this.mounted) {
          setState(() {
            loading = false;
            error = true;
          });
        } else {
          loading = false;
          error = true;
        }
      });
      var data2 = Place.fromSnapshot(data1);
      _places.addAll({
        Booking.fromSnapshot(book).id: data2,
      });
    }

    var dataNow = await FirebaseFirestore.instance
        .collection('bookings')
        .orderBy(
          'timestamp_date',
          descending: true,
        )
        .where(
          'status',
          whereIn: ['in process'],
        )
        .where(
          'userId',
          isEqualTo: FirebaseAuth.instance.currentUser.uid,
        )
        .where(
          'date',
          isEqualTo: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            0,
          ).toString(),
        )
        .get()
        .catchError((error) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: 'Fail',
            body: 'Failed to get data',
          );
          showSimpleNotification(
            Container(child: Text(notification.body)),
            position: NotificationPosition.top,
            background: Colors.red,
          );
          if (this.mounted) {
            setState(() {
              loading = false;
              error = true;
            });
          } else {
            loading = false;
            error = true;
          }
          Navigator.push(
              context,
              SlideRightRoute(
                  page: SomethingWentWrongScreen(
                error: "Something went wrong: ${error.message}",
              )));
        });
    _bookings1 = dataNow.docs;
    if (_bookings1.length != 0) {
      for (dynamic book in _bookings1) {
        var place = await FirebaseFirestore.instance
            .collection('locations')
            .doc(Booking.fromSnapshot(book).placeId)
            .get()
            .catchError((error) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: 'Fail',
            body: 'Failed to get data',
          );
          showSimpleNotification(
            Container(child: Text(notification.body)),
            position: NotificationPosition.top,
            background: Colors.red,
          );
          if (this.mounted) {
            setState(() {
              error = true;
              loading = false;
            });
          } else {
            error = true;
            loading = false;
          }
        });
        slivers.add(book);
        placesSlivers.addAll({book: place});
      }
    }
    setState(() {
      error = false;
      loading = false;
    });
    for (dynamic book in _bookings1) {
      if (Booking.fromSnapshot(book).seen_status == 'unseen') {
        FirebaseFirestore.instance
            .collection('bookings')
            .doc(Booking.fromSnapshot(book).id)
            .update({'seen_status': 'seen1'});
      }
      // else if (Booking.fromSnapshot(book).seen_status == 'seen1') {
      //   FirebaseFirestore.instance
      //       .collection('bookings')
      //       .doc(Booking.fromSnapshot(book).id)
      //       .update({'seen_status': 'seen2'});
      // }
    }

    var unrdataNow = await FirebaseFirestore.instance
        .collection('bookings')
        .orderBy(
          'timestamp_date',
          descending: true,
        )
        .where(
          'status',
          whereIn: ['finished'],
        )
        .where(
          'isRated',
          isEqualTo: false,
        )
        .where(
          'userId',
          isEqualTo: FirebaseAuth.instance.currentUser.uid,
        )
        .get()
        .catchError((error) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: 'Fail',
            body: 'Failed to get data',
          );
          showSimpleNotification(
            Container(child: Text(notification.body)),
            position: NotificationPosition.top,
            background: Colors.red,
          );
          if (this.mounted) {
            setState(() {
              loading = false;
              error = true;
            });
          } else {
            loading = false;
            error = true;
          }
          Navigator.push(
              context,
              SlideRightRoute(
                  page: SomethingWentWrongScreen(
                error: "Something went wrong: ${error.message}",
              )));
        });
    _unrbookings1 = unrdataNow.docs;
    if (_unrbookings1.length != 0) {
      for (dynamic book in _unrbookings1) {
        var place = await FirebaseFirestore.instance
            .collection('locations')
            .doc(Booking.fromSnapshot(book).placeId)
            .get()
            .catchError((error) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: 'Fail',
            body: 'Failed to get data',
          );
          showSimpleNotification(
            Container(child: Text(notification.body)),
            position: NotificationPosition.top,
            background: Colors.red,
          );
          if (this.mounted) {
            setState(() {
              error = true;
              loading = false;
            });
          } else {
            error = true;
            loading = false;
          }
        });
        unratedBooks.add(book);
        unrplacesSlivers.addAll({book: place});
      }
    }
    setState(() {
      error = false;
      loading = false;
    });

    for (dynamic book in _bookings) {
      if (Booking.fromSnapshot(book).seen_status == 'seen1') {
        FirebaseFirestore.instance
            .collection('bookings')
            .doc(Booking.fromSnapshot(book).id)
            .update({'seen_status': 'seen2'});
      }
      // else if (Booking.fromSnapshot(book).seen_status == 'seen1') {
      //   FirebaseFirestore.instance
      //       .collection('bookings')
      //       .doc(Booking.fromSnapshot(book).id)
      //       .update({'seen_status': 'seen2'});
      // }
    }
  }

  // ignore: unused_element
  List<Meeting> _getDataSource() {
    var meetings = <Meeting>[];
    if (_bookings != null) {
      for (var book in _bookings) {
        final DateTime today =
            Booking.fromSnapshot(book).timestamp_date.toDate();
        final DateTime startTime = DateTime(
          today.year,
          today.month,
          today.day,
          DateFormat.Hm().parse(Booking.fromSnapshot(book).from).hour,
          DateFormat.Hm().parse(Booking.fromSnapshot(book).from).minute,
        );
        final DateTime endTime = DateTime(
          today.year,
          today.month,
          today.day,
          DateFormat.Hm().parse(Booking.fromSnapshot(book).to).hour,
          DateFormat.Hm().parse(Booking.fromSnapshot(book).to).minute,
        );
        meetings.add(Meeting(
            _places != null
                ? _places[Booking.fromSnapshot(book).id].name != null
                    ? _places[Booking.fromSnapshot(book).id].name
                    : 'Place'
                : 'Place',
            startTime,
            endTime,
            Booking.fromSnapshot(book).status == 'unfinished'
                ? darkPrimaryColor
                : Colors.red,
            false));
      }
    }
    return meetings;
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : error
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Error',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              )
            : CustomScrollView(scrollDirection: Axis.vertical, slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Container(
                          height: 450,
                          width: size.width * 0.8,
                          child: SfCalendar(
                            dataSource: MeetingDataSource(_getDataSource()),
                            todayHighlightColor: darkPrimaryColor,
                            cellBorderColor: darkPrimaryColor,
                            allowViewNavigation: true,
                            view: CalendarView.month,
                            firstDayOfWeek: 1,
                            monthViewSettings: MonthViewSettings(
                              showAgenda: true,
                              agendaStyle: AgendaStyle(
                                dateTextStyle: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                dayTextStyle: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                appointmentTextStyle: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                slivers.length != 0
                    ? SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Text(
                              'Ongoing',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: darkPrimaryColor,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          for (var book in slivers)
                            FlatButton(
                              onPressed: () {
                                setState(() {
                                  loading = true;
                                });
                                Navigator.push(
                                    context,
                                    SlideRightRoute(
                                      page: OnEventScreen(
                                        booking: book,
                                      ),
                                    ));
                                setState(() {
                                  loading = false;
                                });
                              },
                              child: CardW(
                                ph: 140,
                                bgColor: darkPrimaryColor,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
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
                                                        .format(Booking
                                                                .fromSnapshot(
                                                                    book)
                                                            .timestamp_date
                                                            .toDate())
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: whiteColor,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    Booking.fromSnapshot(book)
                                                            .from +
                                                        ' - ' +
                                                        Booking.fromSnapshot(
                                                                book)
                                                            .to,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: whiteColor,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * 0.1,
                                            ),
                                            Flexible(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      placesSlivers[book] !=
                                                              null
                                                          ? Place.fromSnapshot(
                                                                  placesSlivers[
                                                                      book])
                                                              .name

                                                          //             _places != null
                                                          //                 ? _places[Booking.fromSnapshot(
                                                          //                                     book)
                                                          //                                 .id]
                                                          //                             .name !=
                                                          //                         null
                                                          //                     ? _places[Booking
                                                          //                                 .fromSnapshot(
                                                          //                                     book)
                                                          //                             .id]
                                                          //                         .name
                                                          //                     : 'Place'
                                                          : 'Place',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: whiteColor,
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
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ]),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate([
                          Container(),
                        ]),
                      ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Text(
                          'Upcoming',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkPrimaryColor,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      for (var book in _bookings)
                        CardW(
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          children: [
                                            Text(
                                              DateFormat.yMMMd()
                                                  .format(
                                                      Booking.fromSnapshot(book)
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
                                              Booking.fromSnapshot(book).status,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color:
                                                      Booking.fromSnapshot(book)
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
                                        width: size.width * 0.1,
                                      ),
                                      Flexible(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            children: [
                                              Text(
                                                _places != null
                                                    ? _places[Booking.fromSnapshot(
                                                                        book)
                                                                    .id]
                                                                .name !=
                                                            null
                                                        ? _places[Booking
                                                                    .fromSnapshot(
                                                                        book)
                                                                .id]
                                                            .name
                                                        : 'Place'
                                                    : 'Place',
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                Booking.fromSnapshot(book)
                                                        .from +
                                                    ' - ' +
                                                    Booking.fromSnapshot(book)
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
                                                      Booking.fromSnapshot(book)
                                                          .id]
                                                  .lat,
                                              'lon': _places[
                                                      Booking.fromSnapshot(book)
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
                                  RoundedButton(
                                    width: 0.3,
                                    height: 0.07,
                                    text: 'Book',
                                    press: () {
                                      setState(() {
                                        loading = true;
                                      });
                                      Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: PlaceScreen(
                                            data: {
                                              'name': _places[
                                                      Booking.fromSnapshot(book)
                                                          .id]
                                                  .name, //0
                                              'description': _places[
                                                      Booking.fromSnapshot(book)
                                                          .id]
                                                  .description, //1
                                              'by': _places[
                                                      Booking.fromSnapshot(book)
                                                          .id]
                                                  .by, //2
                                              'lat': _places[
                                                      Booking.fromSnapshot(book)
                                                          .id]
                                                  .lat, //3
                                              'lon': _places[
                                                      Booking.fromSnapshot(book)
                                                          .id]
                                                  .lon, //4
                                              'images': _places[
                                                      Booking.fromSnapshot(book)
                                                          .id]
                                                  .images, //5
                                              'services': _places[
                                                      Booking.fromSnapshot(book)
                                                          .id]
                                                  .services,
                                              'id': _places[
                                                      Booking.fromSnapshot(book)
                                                          .id]
                                                  .id, //7
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
                                  _places != null
                                      ? LabelButton(
                                          isC: false,
                                          reverse: FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser.uid),
                                          containsValue: _places[
                                                  Booking.fromSnapshot(book).id]
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
                                                  .doc(FirebaseAuth
                                                      .instance.currentUser.uid)
                                                  .update({
                                                'favourites':
                                                    FieldValue.arrayUnion([
                                                  _places[Booking.fromSnapshot(
                                                              book)
                                                          .id]
                                                      .id
                                                ])
                                              }).catchError((error) {
                                                PushNotificationMessage
                                                    notification =
                                                    PushNotificationMessage(
                                                  title: 'Fail',
                                                  body:
                                                      'Failed to update favourites',
                                                );
                                                showSimpleNotification(
                                                  Container(
                                                      child: Text(
                                                          notification.body)),
                                                  position:
                                                      NotificationPosition.top,
                                                  background: Colors.red,
                                                );
                                                if (this.mounted) {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                } else {
                                                  loading = false;
                                                }
                                              });
                                            });
                                          },
                                          onTap2: () {
                                            setState(() {
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(FirebaseAuth
                                                      .instance.currentUser.uid)
                                                  .update({
                                                'favourites':
                                                    FieldValue.arrayRemove([
                                                  _places[Booking.fromSnapshot(
                                                              book)
                                                          .id]
                                                      .id
                                                ])
                                              }).catchError((error) {
                                                PushNotificationMessage
                                                    notification =
                                                    PushNotificationMessage(
                                                  title: 'Fail',
                                                  body:
                                                      'Failed to update favourites',
                                                );
                                                showSimpleNotification(
                                                  Container(
                                                      child: Text(
                                                          notification.body)),
                                                  position:
                                                      NotificationPosition.top,
                                                  background: Colors.red,
                                                );
                                                if (this.mounted) {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                } else {
                                                  loading = false;
                                                }
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
                    ],
                  ),
                ),
                unratedBooks.length != 0
                    ? SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Text(
                              'Unrated',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: Colors.blueGrey[900],
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          for (var book in unratedBooks)
                            FlatButton(
                              onPressed: () {
                                setState(() {
                                  loading = true;
                                });
                                Navigator.push(
                                    context,
                                    SlideRightRoute(
                                      page: OnEventScreen(
                                        booking: book,
                                      ),
                                    ));
                                setState(() {
                                  loading = false;
                                });
                              },
                              child: CardW(
                                ph: 140,
                                bgColor: Colors.blueGrey[900],
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
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
                                                        .format(Booking
                                                                .fromSnapshot(
                                                                    book)
                                                            .timestamp_date
                                                            .toDate())
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: whiteColor,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    Booking.fromSnapshot(book)
                                                            .from +
                                                        ' - ' +
                                                        Booking.fromSnapshot(
                                                                book)
                                                            .to,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: whiteColor,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * 0.1,
                                            ),
                                            Flexible(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      unrplacesSlivers[book] !=
                                                              null
                                                          ? Place.fromSnapshot(
                                                                  unrplacesSlivers[
                                                                      book])
                                                              .name

                                                          //             _places != null
                                                          //                 ? _places[Booking.fromSnapshot(
                                                          //                                     book)
                                                          //                                 .id]
                                                          //                             .name !=
                                                          //                         null
                                                          //                     ? _places[Booking
                                                          //                                 .fromSnapshot(
                                                          //                                     book)
                                                          //                             .id]
                                                          //                         .name
                                                          //                     : 'Place'
                                                          : 'Place',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: whiteColor,
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
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ]),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate([
                          Container(),
                        ]),
                      ),
              ]

                // : [
                //     SliverList(
                //       delegate: SliverChildListDelegate(
                //         [
                //           Center(
                //             child: Container(
                //               height: 450,
                //               width: size.width * 0.8,
                //               child: SfCalendar(
                //                 dataSource:
                //                     MeetingDataSource(_getDataSource()),
                //                 todayHighlightColor: darkPrimaryColor,
                //                 cellBorderColor: darkPrimaryColor,
                //                 allowViewNavigation: true,
                //                 view: CalendarView.month,
                //                 firstDayOfWeek: 1,
                //                 monthViewSettings: MonthViewSettings(
                //                   showAgenda: true,
                //                   agendaStyle: AgendaStyle(
                //                     dateTextStyle: GoogleFonts.montserrat(
                //                       textStyle: TextStyle(
                //                         color: darkPrimaryColor,
                //                       ),
                //                     ),
                //                     dayTextStyle: GoogleFonts.montserrat(
                //                       textStyle: TextStyle(
                //                         color: darkPrimaryColor,
                //                       ),
                //                     ),
                //                     appointmentTextStyle:
                //                         GoogleFonts.montserrat(
                //                       textStyle: TextStyle(
                //                         color: whiteColor,
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //           SizedBox(
                //             height: 20,
                //           ),
                //           Center(
                //             child: Text(
                //               'Upcoming',
                //               overflow: TextOverflow.ellipsis,
                //               style: GoogleFonts.montserrat(
                //                 textStyle: TextStyle(
                //                   color: darkPrimaryColor,
                //                   fontSize: 25,
                //                 ),
                //               ),
                //             ),
                //           ),
                //           SizedBox(
                //             height: 15,
                //           ),
                //           for (var book in _bookings)
                //             CardW(
                //               ph: 170,
                //               child: Column(
                //                 children: [
                //                   SizedBox(
                //                     height: 20,
                //                   ),
                //                   Expanded(
                //                     child: Padding(
                //                       padding: const EdgeInsets.fromLTRB(
                //                           10, 0, 10, 0),
                //                       child: Row(
                //                         mainAxisAlignment:
                //                             MainAxisAlignment.start,
                //                         children: [
                //                           Container(
                //                             alignment: Alignment.centerLeft,
                //                             child: Column(
                //                               children: [
                //                                 Text(
                //                                   DateFormat.yMMMd()
                //                                       .format(Booking
                //                                               .fromSnapshot(
                //                                                   book)
                //                                           .timestamp_date
                //                                           .toDate())
                //                                       .toString(),
                //                                   overflow:
                //                                       TextOverflow.ellipsis,
                //                                   style: GoogleFonts
                //                                       .montserrat(
                //                                     textStyle: TextStyle(
                //                                       color:
                //                                           darkPrimaryColor,
                //                                       fontSize: 20,
                //                                       fontWeight:
                //                                           FontWeight.bold,
                //                                     ),
                //                                   ),
                //                                 ),
                //                                 SizedBox(
                //                                   height: 10,
                //                                 ),
                //                                 Text(
                //                                   Booking.fromSnapshot(book)
                //                                       .status,
                //                                   overflow:
                //                                       TextOverflow.ellipsis,
                //                                   style: GoogleFonts
                //                                       .montserrat(
                //                                     textStyle: TextStyle(
                //                                       color: Booking.fromSnapshot(
                //                                                       book)
                //                                                   .status ==
                //                                               'unfinished'
                //                                           ? darkPrimaryColor
                //                                           : Colors.red,
                //                                       fontSize: 15,
                //                                     ),
                //                                   ),
                //                                 ),
                //                               ],
                //                             ),
                //                           ),
                //                           SizedBox(
                //                             width: size.width * 0.1,
                //                           ),
                //                           Flexible(
                //                             child: Container(
                //                               alignment:
                //                                   Alignment.centerLeft,
                //                               child: Column(
                //                                 children: [
                //                                   Text(
                //                                     _places != null
                //                                         ? _places[Booking.fromSnapshot(book)
                //                                                         .id]
                //                                                     .name !=
                //                                                 null
                //                                             ? _places[Booking.fromSnapshot(
                //                                                         book)
                //                                                     .id]
                //                                                 .name
                //                                             : 'Place'
                //                                         : 'Place',
                //                                     maxLines: 1,
                //                                     overflow: TextOverflow
                //                                         .ellipsis,
                //                                     style: GoogleFonts
                //                                         .montserrat(
                //                                       textStyle: TextStyle(
                //                                         color:
                //                                             darkPrimaryColor,
                //                                         fontSize: 15,
                //                                       ),
                //                                     ),
                //                                   ),
                //                                   SizedBox(
                //                                     height: 10,
                //                                   ),
                //                                   Text(
                //                                     Booking.fromSnapshot(
                //                                                 book)
                //                                             .from +
                //                                         ' - ' +
                //                                         Booking.fromSnapshot(
                //                                                 book)
                //                                             .to,
                //                                     maxLines: 1,
                //                                     overflow: TextOverflow
                //                                         .ellipsis,
                //                                     style: GoogleFonts
                //                                         .montserrat(
                //                                       textStyle: TextStyle(
                //                                         color:
                //                                             darkPrimaryColor,
                //                                         fontSize: 15,
                //                                       ),
                //                                     ),
                //                                   ),
                //                                 ],
                //                               ),
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     ),
                //                   ),
                //                   Row(
                //                     mainAxisAlignment:
                //                         MainAxisAlignment.center,
                //                     children: <Widget>[
                //                       RoundedButton(
                //                         width: 0.3,
                //                         height: 0.07,
                //                         text: 'On Map',
                //                         press: () {
                //                           setState(() {
                //                             loading = true;
                //                           });
                //                           Navigator.push(
                //                             context,
                //                             SlideRightRoute(
                //                               page: MapScreen(
                //                                 data: {
                //                                   'lat': _places[Booking
                //                                               .fromSnapshot(
                //                                                   book)
                //                                           .id]
                //                                       .lat,
                //                                   'lon': _places[Booking
                //                                               .fromSnapshot(
                //                                                   book)
                //                                           .id]
                //                                       .lon
                //                                 },
                //                               ),
                //                             ),
                //                           );
                //                           setState(() {
                //                             loading = false;
                //                           });
                //                         },
                //                         color: darkPrimaryColor,
                //                         textColor: whiteColor,
                //                       ),
                //                       SizedBox(
                //                         width: size.width * 0.04,
                //                       ),
                //                       RoundedButton(
                //                         width: 0.3,
                //                         height: 0.07,
                //                         text: 'Book',
                //                         press: () {
                //                           setState(() {
                //                             loading = true;
                //                           });
                //                           Navigator.push(
                //                             context,
                //                             SlideRightRoute(
                //                               page: PlaceScreen(
                //                                 data: {
                //                                   'name': _places[Booking
                //                                               .fromSnapshot(
                //                                                   book)
                //                                           .id]
                //                                       .name, //0
                //                                   'description': _places[
                //                                           Booking.fromSnapshot(
                //                                                   book)
                //                                               .id]
                //                                       .description, //1
                //                                   'by': _places[Booking
                //                                               .fromSnapshot(
                //                                                   book)
                //                                           .id]
                //                                       .by, //2
                //                                   'lat': _places[Booking
                //                                               .fromSnapshot(
                //                                                   book)
                //                                           .id]
                //                                       .lat, //3
                //                                   'lon': _places[Booking
                //                                               .fromSnapshot(
                //                                                   book)
                //                                           .id]
                //                                       .lon, //4
                //                                   'images': _places[Booking
                //                                               .fromSnapshot(
                //                                                   book)
                //                                           .id]
                //                                       .images, //5
                //                                   'services': _places[Booking
                //                                               .fromSnapshot(
                //                                                   book)
                //                                           .id]
                //                                       .services,
                //                                   'id': _places[Booking
                //                                               .fromSnapshot(
                //                                                   book)
                //                                           .id]
                //                                       .id, //7
                //                                 },
                //                               ),
                //                             ),
                //                           );
                //                           setState(() {
                //                             loading = false;
                //                           });
                //                         },
                //                         color: darkPrimaryColor,
                //                         textColor: whiteColor,
                //                       ),
                //                       _places != null
                //                           ? LabelButton(
                //                               isC: false,
                //                               reverse: FirebaseFirestore
                //                                   .instance
                //                                   .collection('users')
                //                                   .doc(FirebaseAuth.instance
                //                                       .currentUser.uid),
                //                               containsValue: _places[
                //                                       Booking.fromSnapshot(
                //                                               book)
                //                                           .id]
                //                                   .id,
                //                               color1: Colors.red,
                //                               color2: lightPrimaryColor,
                //                               ph: 45,
                //                               pw: 45,
                //                               size: 40,
                //                               onTap: () {
                //                                 setState(() {
                //                                   FirebaseFirestore.instance
                //                                       .collection('users')
                //                                       .doc(FirebaseAuth
                //                                           .instance
                //                                           .currentUser
                //                                           .uid)
                //                                       .update({
                //                                     'favourites': FieldValue
                //                                         .arrayUnion([
                //                                       _places[Booking
                //                                                   .fromSnapshot(
                //                                                       book)
                //                                               .id]
                //                                           .id
                //                                     ])
                //                                   });
                //                                 });
                //                               },
                //                               onTap2: () {
                //                                 setState(() {
                //                                   FirebaseFirestore.instance
                //                                       .collection('users')
                //                                       .doc(FirebaseAuth
                //                                           .instance
                //                                           .currentUser
                //                                           .uid)
                //                                       .update({
                //                                     'favourites': FieldValue
                //                                         .arrayRemove([
                //                                       _places[Booking
                //                                                   .fromSnapshot(
                //                                                       book)
                //                                               .id]
                //                                           .id
                //                                     ])
                //                                   });
                //                                 });
                //                               },
                //                             )
                //                           : Container(),
                //                     ],
                //                   ),
                //                   SizedBox(
                //                     height: 20,
                //                   ),
                //                 ],
                //               ),
                //             ),
                //         ],
                //       ),
                //     ),
                //   ],
                );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
