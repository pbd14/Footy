import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Booking.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Models/PushNotificationMessage.dart';
import 'package:flutter_complete_guide/Screens/HomeScreen/home_screen.dart';
import 'package:flutter_complete_guide/Screens/OnEventScreen/on_event_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/label_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class History1 extends StatefulWidget {
  @override
  _History1State createState() => _History1State();
}

class _History1State extends State<History1>
    with AutomaticKeepAliveClientMixin<History1> {
  @override
  bool get wantKeepAlive => true;
  bool loading = true;
  bool error = true;
  List<QueryDocumentSnapshot> _bookings = [];
  Map<String, DocumentSnapshot> _places = {};
  Map<QueryDocumentSnapshot, DocumentSnapshot> placesSlivers = {};
  Map<QueryDocumentSnapshot, DocumentSnapshot> unrplacesSlivers = {};
  List _bookings1 = [];
  List _unrbookings1 = [];
  List<QueryDocumentSnapshot> slivers = [];
  List unratedBooks = [];
  List<Widget> sliversList = [];

  StreamSubscription<QuerySnapshot> ordinaryBookSubscr;
  StreamSubscription<QuerySnapshot> inprocessBookSubscr;
  StreamSubscription<QuerySnapshot> unratedBookSubscr;

  @override
  void dispose() {
    ordinaryBookSubscr.cancel();
    inprocessBookSubscr.cancel();
    unratedBookSubscr.cancel();
    super.dispose();
  }

  Future<void> ordinaryBookPrep(List<QueryDocumentSnapshot> _bookings) async {
    DocumentSnapshot customOB;
    for (QueryDocumentSnapshot book in _bookings) {
      customOB = await FirebaseFirestore.instance
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
      setState(() {
        _places.addAll({
          Booking.fromSnapshot(book).id: customOB,
        });
      });
    }
    for (QueryDocumentSnapshot book in _bookings) {
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

  Future<void> inprocessBookPrep(List<QueryDocumentSnapshot> _bookings1) async {
    DocumentSnapshot customIB;
    if (_bookings1.length != 0) {
      for (QueryDocumentSnapshot book in _bookings1) {
        customIB = await FirebaseFirestore.instance
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
        setState(() {
          slivers.add(book);
          placesSlivers.addAll({book: customIB});
        });
      }
    }
    for (QueryDocumentSnapshot book in _bookings1) {
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
  }

  Future<void> unratedBookPrep(
      List<QueryDocumentSnapshot> _unrbookings1) async {
    DocumentSnapshot customUB;
    if (_unrbookings1.length != 0) {
      for (QueryDocumentSnapshot book in _unrbookings1) {
        customUB = await FirebaseFirestore.instance
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
        setState(() {
          unratedBooks.add(book);
          unrplacesSlivers.addAll({book: customUB});
        });
      }
    }
  }

  Future<void> loadData() async {
    ordinaryBookSubscr = FirebaseFirestore.instance
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
        .snapshots()
        .listen((bookings) {
          setState(() {
            _bookings = bookings.docs;
            ordinaryBookPrep(bookings.docs);
          });
        });

    inprocessBookSubscr = FirebaseFirestore.instance
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
        .snapshots()
        .listen((bookings) {
          setState(() {
            _bookings1 = bookings.docs;
            inprocessBookPrep(bookings.docs);
          });
        });

    unratedBookSubscr = FirebaseFirestore.instance
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
        .snapshots()
        .listen((bookings) {
          setState(() {
            _unrbookings1 = bookings.docs;
            unratedBookPrep(bookings.docs);
          });
        });

    if (this.mounted) {
      setState(() {
        error = false;
        loading = false;
      });
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
                ? _places[Booking.fromSnapshot(book).id] != null
                    ? _places[Booking.fromSnapshot(book).id].data()['name']
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

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    _bookings = [];
    _places = {};
    placesSlivers = {};
    unrplacesSlivers = {};
    _bookings1 = [];
    _unrbookings1 = [];
    slivers = [];
    unratedBooks = [];
    sliversList = [];
    ordinaryBookSubscr.cancel();
    inprocessBookSubscr.cancel();
    unratedBookSubscr.cancel();
    loadData();

    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
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
            : RefreshIndicator(
                onRefresh: _refresh,
                child:
                    CustomScrollView(scrollDirection: Axis.vertical, slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: Container(
                            height: 450,
                            width: size.width * 0.9,
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
                  // Ongoing
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
                            for (QueryDocumentSnapshot book in slivers)
                              TextButton(
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
                                child: Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Card(
                                    color: darkPrimaryColor,
                                    margin: EdgeInsets.all(5),
                                    elevation: 10,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: size.width * 0.5,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    placesSlivers[book]
                                                                .data()[
                                                                    'services']
                                                                .where(
                                                                    (service) {
                                                              if (service[
                                                                      'id'] ==
                                                                  book.data()[
                                                                      'serviceId']) {
                                                                return true;
                                                              } else {
                                                                return false;
                                                              }
                                                            }).first['name'] !=
                                                            null
                                                        ? placesSlivers[book]
                                                            .data()['services']
                                                            .where((service) {
                                                            if (service['id'] ==
                                                                book.data()[
                                                                    'serviceId']) {
                                                              return true;
                                                            } else {
                                                              return false;
                                                            }
                                                          }).first['name']
                                                        : 'Service',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                          color: whiteColor,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    placesSlivers[book] != null
                                                        ? Place.fromSnapshot(
                                                                placesSlivers[
                                                                    book])
                                                            .name
                                                        : 'Place',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                          color: whiteColor,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    Booking.fromSnapshot(book)
                                                        .status,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Booking.fromSnapshot(
                                                                        book)
                                                                    .status ==
                                                                'unfinished'
                                                            ? whiteColor
                                                            : Colors.red,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                width: size.width * 0.3,
                                                child: Column(
                                                  children: [
                                                    IconButton(
                                                      iconSize: 30,
                                                      icon: Icon(
                                                        CupertinoIcons
                                                            .map_pin_ellipse,
                                                        color: whiteColor,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        Navigator.push(
                                                          context,
                                                          SlideRightRoute(
                                                            page: MapPage(
                                                              isLoading: true,
                                                              isAppBar: true,
                                                              data: {
                                                                'lat': Place.fromSnapshot(
                                                                        placesSlivers[
                                                                            book])
                                                                    .lat,
                                                                'lon': Place.fromSnapshot(
                                                                        placesSlivers[
                                                                            book])
                                                                    .lon
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
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
                  // Upcoming
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
                                color: darkColor,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        for (QueryDocumentSnapshot book in _bookings)
                          CupertinoButton(
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
                            padding: EdgeInsets.zero,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10.0),
                              // padding: EdgeInsets.all(10),
                              child: Card(
                                margin: EdgeInsets.all(5),
                                elevation: 10,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: size.width * 0.5,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat.yMMMd()
                                                    .format(
                                                        Booking.fromSnapshot(
                                                                book)
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
                                                Booking.fromSnapshot(book)
                                                        .from +
                                                    ' - ' +
                                                    Booking.fromSnapshot(book)
                                                        .to,
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
                                                _places[book.id] !=
                                                        null
                                                    ? _places[book.id]
                                                        .data()['services']
                                                        .where((service) {
                                                        if (service['id'] ==
                                                            book.data()[
                                                                'serviceId']) {
                                                          return true;
                                                        } else {
                                                          return false;
                                                        }
                                                      }).first['name']
                                                    : 'Service',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      color: darkPrimaryColor,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                _places[book.id] != null
                                                    ? _places[Booking.fromSnapshot(
                                                                        book)
                                                                    .id]
                                                                .data() !=
                                                            null
                                                        ? _places[Booking
                                                                    .fromSnapshot(
                                                                        book)
                                                                .id]
                                                            .data()['name']
                                                        : 'Place'
                                                    : 'Place',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      color: darkPrimaryColor,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                Booking.fromSnapshot(book)
                                                    .status,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: Booking.fromSnapshot(
                                                                    book)
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
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            width: size.width * 0.3,
                                            child: Column(
                                              // crossAxisAlignment:
                                              //     CrossAxisAlignment.end,
                                              children: [
                                                _places[book.id] != null
                                                    ? LabelButton(
                                                        isC: false,
                                                        reverse:
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid),
                                                        containsValue:
                                                            _places[book.id].id,
                                                        color1: Colors.red,
                                                        color2:
                                                            lightPrimaryColor,
                                                        size: 30,
                                                        onTap: () {
                                                          setState(() {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid)
                                                                .update({
                                                              'favourites':
                                                                  FieldValue
                                                                      .arrayUnion([
                                                                _places[Booking.fromSnapshot(
                                                                            book)
                                                                        .id]
                                                                    .id
                                                              ])
                                                            }).catchError(
                                                                    (error) {
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
                                                                        notification
                                                                            .body)),
                                                                position:
                                                                    NotificationPosition
                                                                        .top,
                                                                background:
                                                                    Colors.red,
                                                              );
                                                              if (this
                                                                  .mounted) {
                                                                setState(() {
                                                                  loading =
                                                                      false;
                                                                });
                                                              } else {
                                                                loading = false;
                                                              }
                                                            });
                                                          });
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                              backgroundColor:
                                                                  darkPrimaryColor,
                                                              content: Text(
                                                                'Saved to favourites',
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    color:
                                                                        whiteColor,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        onTap2: () {
                                                          setState(() {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid)
                                                                .update({
                                                              'favourites':
                                                                  FieldValue
                                                                      .arrayRemove([
                                                                _places[Booking.fromSnapshot(
                                                                            book)
                                                                        .id]
                                                                    .id
                                                              ])
                                                            }).catchError(
                                                                    (error) {
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
                                                                        notification
                                                                            .body)),
                                                                position:
                                                                    NotificationPosition
                                                                        .top,
                                                                background:
                                                                    Colors.red,
                                                              );
                                                              if (this
                                                                  .mounted) {
                                                                setState(() {
                                                                  loading =
                                                                      false;
                                                                });
                                                              } else {
                                                                loading = false;
                                                              }
                                                            });
                                                          });
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                              backgroundColor:
                                                                  Colors.red,
                                                              content: Text(
                                                                'Removed from favourites',
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    color:
                                                                        whiteColor,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Container(),
                                                SizedBox(height: 10),
                                                IconButton(
                                                  iconSize: 30,
                                                  icon: Icon(
                                                    CupertinoIcons
                                                        .map_pin_ellipse,
                                                    color: darkPrimaryColor,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      loading = true;
                                                    });
                                                    Navigator.push(
                                                      context,
                                                      SlideRightRoute(
                                                        page: MapPage(
                                                          isAppBar: true,
                                                          isLoading: true,
                                                          data: {
                                                            'lat': _places[Booking
                                                                        .fromSnapshot(
                                                                            book)
                                                                    .id]
                                                                .data()['lat'],
                                                            'lon': _places[Booking
                                                                        .fromSnapshot(
                                                                            book)
                                                                    .id]
                                                                .data()['lon']
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                  },
                                                ),
                                                // IconButton(
                                                //   icon: Icon(
                                                //     CupertinoIcons.book,
                                                //     color: darkPrimaryColor,
                                                //   ),
                                                //   onPressed: ()  {
                                                //     setState(() {
                                                //       loading = true;
                                                //     });
                                                //     Navigator.push(
                                                //       context,
                                                //       SlideRightRoute(
                                                //         page: PlaceScreen(
                                                //           data: {
                                                //             'name':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .name, //0
                                                //             'description': Place
                                                //                     .fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                 .description, //1
                                                //             'by':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .by, //2
                                                //             'lat':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .lat, //3
                                                //             'lon':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .lon, //4
                                                //             'images':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .images, //5
                                                //             'services':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .services,
                                                //             'rates':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .rates,
                                                //             'id':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .id, //7
                                                //           },
                                                //         ),
                                                //       ),
                                                //     );
                                                //     setState(() {
                                                //       loading = false;
                                                //     });
                                                //   },
                                                // ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Unrated
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
                              TextButton(
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
                                child: Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  // padding: EdgeInsets.all(10),
                                  child: Card(
                                    color: darkColor,
                                    margin: EdgeInsets.all(5),
                                    elevation: 10,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: size.width * 0.5,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    unrplacesSlivers[book] !=
                                                            null
                                                        ? Place.fromSnapshot(
                                                                unrplacesSlivers[
                                                                    book])
                                                            .name
                                                        : 'Place',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                          color: whiteColor,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    Booking.fromSnapshot(book)
                                                        .status,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Booking.fromSnapshot(
                                                                        book)
                                                                    .status ==
                                                                'unfinished'
                                                            ? whiteColor
                                                            : Colors.red,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                width: size.width * 0.3,
                                                child: Column(
                                                  children: [
                                                    IconButton(
                                                      iconSize: 30,
                                                      icon: Icon(
                                                        CupertinoIcons
                                                            .map_pin_ellipse,
                                                        color: whiteColor,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        Navigator.push(
                                                          context,
                                                          SlideRightRoute(
                                                            page: MapPage(
                                                              isLoading: true,
                                                              isAppBar: true,
                                                              data: {
                                                                'lat': Place.fromSnapshot(
                                                                        unrplacesSlivers[
                                                                            book])
                                                                    .lat,
                                                                'lon': Place.fromSnapshot(
                                                                        unrplacesSlivers[
                                                                            book])
                                                                    .lon
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // CardW(
                                //   ph: 140,
                                //   bgColor: Colors.blueGrey[900],
                                //   child: Column(
                                //     children: [
                                //       SizedBox(
                                //         height: 20,
                                //       ),
                                //       Expanded(
                                //         child: Padding(
                                //           padding: const EdgeInsets.fromLTRB(
                                //               10, 0, 10, 0),
                                //           child: Row(
                                //             mainAxisAlignment:
                                //                 MainAxisAlignment.center,
                                //             children: [
                                //               Container(
                                //                 alignment: Alignment.centerLeft,
                                //                 child: Column(
                                //                   children: [
                                //                     Text(
                                //                       DateFormat.yMMMd()
                                //                           .format(Booking
                                //                                   .fromSnapshot(
                                //                                       book)
                                //                               .timestamp_date
                                //                               .toDate())
                                //                           .toString(),
                                //                       overflow:
                                //                           TextOverflow.ellipsis,
                                //                       style:
                                //                           GoogleFonts.montserrat(
                                //                         textStyle: TextStyle(
                                //                           color: whiteColor,
                                //                           fontSize: 20,
                                //                           fontWeight:
                                //                               FontWeight.bold,
                                //                         ),
                                //                       ),
                                //                     ),
                                //                     SizedBox(
                                //                       height: 10,
                                //                     ),
                                //                     Text(
                                //                       Booking.fromSnapshot(book)
                                //                               .from +
                                //                           ' - ' +
                                //                           Booking.fromSnapshot(
                                //                                   book)
                                //                               .to,
                                //                       overflow:
                                //                           TextOverflow.ellipsis,
                                //                       style:
                                //                           GoogleFonts.montserrat(
                                //                         textStyle: TextStyle(
                                //                           color: whiteColor,
                                //                           fontSize: 15,
                                //                         ),
                                //                       ),
                                //                     ),
                                //                   ],
                                //                 ),
                                //               ),
                                //               SizedBox(
                                //                 width: size.width * 0.1,
                                //               ),
                                //               Flexible(
                                //                 child: Container(
                                //                   alignment: Alignment.centerLeft,
                                //                   child: Column(
                                //                     children: [
                                //                       Text(
                                //                         unrplacesSlivers[book] !=
                                //                                 null
                                //                             ? Place.fromSnapshot(
                                //                                     unrplacesSlivers[
                                //                                         book])
                                //                                 .name

                                //                             //             _places != null
                                //                             //                 ? _places[Booking.fromSnapshot(
                                //                             //                                     book)
                                //                             //                                 .id]
                                //                             //                             .name !=
                                //                             //                         null
                                //                             //                     ? _places[Booking
                                //                             //                                 .fromSnapshot(
                                //                             //                                     book)
                                //                             //                             .id]
                                //                             //                         .name
                                //                             //                     : 'Place'
                                //                             : 'Place',
                                //                         overflow:
                                //                             TextOverflow.ellipsis,
                                //                         style: GoogleFonts
                                //                             .montserrat(
                                //                           textStyle: TextStyle(
                                //                             color: whiteColor,
                                //                             fontSize: 15,
                                //                           ),
                                //                         ),
                                //                       ),
                                //                     ],
                                //                   ),
                                //                 ),
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //       ),
                                //       SizedBox(
                                //         height: 20,
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ),
                          ]),
                        )
                      : SliverList(
                          delegate: SliverChildListDelegate([
                            Container(),
                          ]),
                        ),
                ]),
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
