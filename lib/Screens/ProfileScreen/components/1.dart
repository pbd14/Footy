import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Screens/OnEventScreen/on_event_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants.dart';

class ProfileScreen1 extends StatefulWidget {
  @override
  _ProfileScreen1State createState() => _ProfileScreen1State();
}

class _ProfileScreen1State extends State<ProfileScreen1> {
  bool loading = true;

  List notifs = [];
  List updatedNotifications = [];

  DocumentSnapshot user;

  // StreamSubscription<DocumentSnapshot> notifications;

  String getDate(int millisecondsSinceEpoch) {
    String date = '';
    DateTime d = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    if (d.year == DateTime.now().year) {
      if (d.month == DateTime.now().month) {
        if (d.day == DateTime.now().day) {
          date = 'today';
        } else {
          int n = DateTime.now().day - d.day;
          switch (n) {
            case 1:
              date = 'yesterday';
              break;
            case 2:
              date = '2 days ago';
              break;
            case 3:
              date = n.toString() + ' days ago';
              break;
            case 4:
              date = n.toString() + ' days ago';
              break;
            default:
              date = n.toString() + ' days ago';
          }
        }
      } else {
        int n = DateTime.now().month - d.month;
        switch (n) {
          case 1:
            date = 'last month';
            break;
          case 2:
            date = n.toString() + ' months ago';
            break;
          case 3:
            date = n.toString() + ' months ago';
            break;
          case 4:
            date = n.toString() + ' months ago';
            break;
          default:
            date = n.toString() + ' months ago';
        }
      }
    } else {
      int n = DateTime.now().year - d.year;
      switch (n) {
        case 1:
          date = 'last year';
          break;
        case 2:
          date = n.toString() + ' years ago';
          break;
        case 3:
          date = n.toString() + ' years ago';
          break;
        case 4:
          date = n.toString() + ' years ago';
          break;
        default:
          date = n.toString() + ' years ago';
      }
    }
    return date;
  }

  Future<void> prepare() async {
    user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();

    if (user.exists) {
      if (user.data()['notifications'] != null) {
        if (user.data()['notifications'].length != 0) {
          if (user.data()['notifications'].length > 50) {
            for (int i = user.data()['notifications'].length - 1;
                i >= user.data()['notifications'].length - 50;
                i--) {
              if (this.mounted) {
                setState(() {
                  notifs.add(user.data()['notifications'][i]);
                });
              } else {
                notifs.add(user.data()['notifications'][i]);
              }
            }
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser.uid)
                .update({
              'notifications': notifs.reversed,
            });
          } else {
            for (Map notif in user.data()['notifications'].reversed) {
              if (this.mounted) {
                setState(() {
                  notifs.add(notif);
                });
              } else {
                notifs.add(notif);
              }
            }
          }
        }
      }
    }

    for (Map notif in notifs.reversed) {
      Map middleNotif = notif;
      if (!middleNotif['seen']) {
        middleNotif['seen'] = true;
      }
      updatedNotifications.add(middleNotif);
    }
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({'notifications': updatedNotifications});
    if (this.mounted) {
      setState(() {
        loading = false;
      });
    } else {
      loading = false;
    }
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    notifs = [];
    updatedNotifications = [];
    prepare();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : RefreshIndicator(
            onRefresh: _refresh,
            child: Scaffold(
              body: Column(
                children: [
                  SizedBox(height: 30),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 10),
                      itemCount: notifs.length,
                      itemBuilder: (BuildContext context, int index) =>
                          CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (notifs[index]['type'] == 'offer_accepted') {
                            setState(() {
                              loading = true;
                            });
                            Navigator.push(
                              context,
                              SlideRightRoute(
                                  page: OnEventScreen(
                                bookingId: notifs[index]['bookingId'],
                              )),
                            );
                            setState(() {
                              loading = false;
                            });
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          // padding: EdgeInsets.all(10),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                            color: notifs[index]['type'] == 'booking_canceled'
                                ? Colors.red
                                : whiteColor,
                            margin: EdgeInsets.all(5),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notifs[index]['title'],
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: notifs[index]['type'] ==
                                                        'booking_canceled'
                                                    ? whiteColor
                                                    : darkColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            notifs[index]['text'],
                                            maxLines: 20,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                  color: notifs[index]
                                                              ['type'] ==
                                                          'booking_canceled'
                                                      ? whiteColor
                                                      : darkColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Company: ' +
                                                notifs[index]['companyName'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                  color: notifs[index]
                                                              ['type'] ==
                                                          'booking_canceled'
                                                      ? whiteColor
                                                      : darkColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            getDate(notifs[index]['date']
                                                .millisecondsSinceEpoch),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                  color: notifs[index]
                                                              ['type'] ==
                                                          'booking_canceled'
                                                      ? whiteColor
                                                      : darkColor,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    notifs[index]['seen']
                                        ? Container()
                                        : Center(
                                            child: Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: primaryColor),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));

    // Padding(
    //     padding: const EdgeInsets.all(10.0),
    //     child: CustomScrollView(
    //       scrollDirection: Axis.vertical,
    //       slivers: slivers.length != 0
    //           ? [
    //               SliverGrid.count(
    //                 children: [
    //                   for (var book in slivers)
    //                     FlatButton(
    //                       padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
    //                       onPressed: () {
    //                         setState(() {
    //                           loading = true;
    //                         });
    //                         Navigator.push(
    //                             context,
    //                             SlideRightRoute(
    //                               page: OnEventScreen(
    //                                 booking: book,
    //                               ),
    //                             ));
    //                         setState(() {
    //                           loading = false;
    //                         });
    //                       },
    //                       child: Container(
    //                         alignment: Alignment.center,
    //                         color: darkPrimaryColor,
    //                         child: Text(
    //                           placesSlivers[book] != null
    //                               ? Place.fromSnapshot(placesSlivers[book])
    //                                   .name
    //                               : 'Place',
    //                           overflow: TextOverflow.ellipsis,
    //                           style: GoogleFonts.montserrat(
    //                             textStyle: TextStyle(
    //                               color: whiteColor,
    //                               fontSize: 20,
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                 ],
    //                 crossAxisCount: 2,
    //               ),
    //               SliverList(
    //                 delegate: SliverChildListDelegate(
    //                   [
    //                     for (var book in _bookings)
    //                       CardW(
    //                         width: 0.8,
    //                         ph: 170,
    //                         child: Column(
    //                           children: [
    //                             SizedBox(
    //                               height: 20,
    //                             ),
    //                             Expanded(
    //                               child: Padding(
    //                                 padding: const EdgeInsets.fromLTRB(
    //                                     10, 0, 10, 0),
    //                                 child: Row(
    //                                   mainAxisAlignment:
    //                                       MainAxisAlignment.center,
    //                                   children: [
    //                                     Container(
    //                                       alignment: Alignment.centerLeft,
    //                                       child: Column(
    //                                         children: [
    //                                           Text(
    //                                             DateFormat.yMMMd()
    //                                                 .format(Booking
    //                                                         .fromSnapshot(
    //                                                             book)
    //                                                     .timestamp_date
    //                                                     .toDate())
    //                                                 .toString(),
    //                                             overflow:
    //                                                 TextOverflow.ellipsis,
    //                                             style:
    //                                                 GoogleFonts.montserrat(
    //                                               textStyle: TextStyle(
    //                                                 color: darkPrimaryColor,
    //                                                 fontSize: 20,
    //                                                 fontWeight:
    //                                                     FontWeight.bold,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                           SizedBox(
    //                                             height: 10,
    //                                           ),
    //                                           Text(
    //                                             Booking.fromSnapshot(book)
    //                                                 .status,
    //                                             overflow:
    //                                                 TextOverflow.ellipsis,
    //                                             style:
    //                                                 GoogleFonts.montserrat(
    //                                               textStyle: TextStyle(
    //                                                 color: Booking.fromSnapshot(
    //                                                                 book)
    //                                                             .status ==
    //                                                         'unfinished'
    //                                                     ? darkPrimaryColor
    //                                                     : Colors.red,
    //                                                 fontSize: 15,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     ),
    //                                     SizedBox(
    //                                       width: size.width * 0.1,
    //                                     ),
    //                                     Flexible(
    //                                       child: Container(
    //                                         alignment: Alignment.centerLeft,
    //                                         child: Column(
    //                                           children: [
    //                                             Text(
    //                                               _places != null
    //                                                   ? _places[Booking.fromSnapshot(
    //                                                                       book)
    //                                                                   .id]
    //                                                               .name !=
    //                                                           null
    //                                                       ? _places[Booking
    //                                                                   .fromSnapshot(
    //                                                                       book)
    //                                                               .id]
    //                                                           .name
    //                                                       : 'Place'
    //                                                   : 'Place',
    //                                               overflow:
    //                                                   TextOverflow.ellipsis,
    //                                               style: GoogleFonts
    //                                                   .montserrat(
    //                                                 textStyle: TextStyle(
    //                                                   color:
    //                                                       darkPrimaryColor,
    //                                                   fontSize: 15,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                             SizedBox(
    //                                               height: 10,
    //                                             ),
    //                                             Text(
    //                                               Booking.fromSnapshot(book)
    //                                                       .from +
    //                                                   ' - ' +
    //                                                   Booking.fromSnapshot(
    //                                                           book)
    //                                                       .to,
    //                                               overflow:
    //                                                   TextOverflow.ellipsis,
    //                                               style: GoogleFonts
    //                                                   .montserrat(
    //                                                 textStyle: TextStyle(
    //                                                   color:
    //                                                       darkPrimaryColor,
    //                                                   fontSize: 15,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                             ),
    //                             Row(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.center,
    //                               children: <Widget>[
    //                                 RoundedButton(
    //                                   width: 0.3,
    //                                   height: 0.07,
    //                                   text: 'On Map',
    //                                   press: () {},
    //                                   color: darkPrimaryColor,
    //                                   textColor: whiteColor,
    //                                 ),
    //                                 SizedBox(
    //                                   width: size.width * 0.04,
    //                                 ),
    //                                 RoundedButton(
    //                                   width: 0.3,
    //                                   height: 0.07,
    //                                   text: 'Book',
    //                                   press: () {},
    //                                   color: darkPrimaryColor,
    //                                   textColor: whiteColor,
    //                                 ),
    //                                 _places != null
    //                                     ? LabelButton(
    //                                         isC: false,
    //                                         reverse: FirebaseFirestore
    //                                             .instance
    //                                             .collection('users')
    //                                             .doc(FirebaseAuth.instance
    //                                                 .currentUser.uid),
    //                                         containsValue: _places[
    //                                                 Booking.fromSnapshot(
    //                                                         book)
    //                                                     .id]
    //                                             .id,
    //                                         color1: Colors.red,
    //                                         color2: lightPrimaryColor,
    //                                         ph: 45,
    //                                         pw: 45,
    //                                         size: 40,
    //                                         onTap: () {
    //                                           setState(() {
    //                                             FirebaseFirestore.instance
    //                                                 .collection('users')
    //                                                 .doc(FirebaseAuth
    //                                                     .instance
    //                                                     .currentUser
    //                                                     .uid)
    //                                                 .update({
    //                                               'favourites': FieldValue
    //                                                   .arrayUnion([
    //                                                 _places[Booking
    //                                                             .fromSnapshot(
    //                                                                 book)
    //                                                         .id]
    //                                                     .id
    //                                               ])
    //                                             });
    //                                           });
    //                                         },
    //                                         onTap2: () {
    //                                           setState(() {
    //                                             FirebaseFirestore.instance
    //                                                 .collection('users')
    //                                                 .doc(FirebaseAuth
    //                                                     .instance
    //                                                     .currentUser
    //                                                     .uid)
    //                                                 .update({
    //                                               'favourites': FieldValue
    //                                                   .arrayRemove([
    //                                                 _places[Booking
    //                                                             .fromSnapshot(
    //                                                                 book)
    //                                                         .id]
    //                                                     .id
    //                                               ])
    //                                             });
    //                                           });
    //                                         },
    //                                       )
    //                                     : Container(),
    //                               ],
    //                             ),
    //                             SizedBox(
    //                               height: 20,
    //                             ),
    //                           ],
    //                         ),
    //                       ),

    //                     // CardW(
    //                     //   width: 0.8,
    //                     //   height: 0.45,
    //                     //   child: Center(
    //                     //     child: Padding(
    //                     //       padding: EdgeInsets.fromLTRB(20, 0, 15, 0),
    //                     //       child: Column(
    //                     //         children: <Widget>[
    //                     //           SizedBox(
    //                     //             height: size.height * 0.04,
    //                     //           ),
    //                     //           Text(
    //                     //             DateFormat.yMMMd()
    //                     //                 .format(Booking.fromSnapshot(book)
    //                     //                     .timestamp_date
    //                     //                     .toDate())
    //                     //                 .toString(),
    //                     //             overflow: TextOverflow.ellipsis,
    //                     //             style: GoogleFonts.montserrat(
    //                     //               textStyle: TextStyle(
    //                     //                 color: darkPrimaryColor,
    //                     //                 fontSize: 25,
    //                     //                 fontWeight: FontWeight.bold,
    //                     //               ),
    //                     //             ),
    //                     //           ),
    //                     //           Text(
    //                     //             Booking.fromSnapshot(book).from +
    //                     //                 ' - ' +
    //                     //                 Booking.fromSnapshot(book).to,
    //                     //             overflow: TextOverflow.ellipsis,
    //                     //             style: GoogleFonts.montserrat(
    //                     //               textStyle: TextStyle(
    //                     //                 color: darkPrimaryColor,
    //                     //                 fontSize: 20,
    //                     //               ),
    //                     //             ),
    //                     //           ),
    //                     //           Text(
    //                     //             // _places != null
    //                     //             //     ? _places[Booking.fromSnapshot(book)
    //                     //             //                     .id]
    //                     //             //                 .name !=
    //                     //             //             null
    //                     //             //         ? _places[Booking.fromSnapshot(
    //                     //             //                     book)
    //                     //             //                 .id]
    //                     //             //             .name
    //                     //             //         : 'Place'
    //                     //             //     : 'Place',
    //                     //             'Place',
    //                     //             overflow: TextOverflow.ellipsis,
    //                     //             style: GoogleFonts.montserrat(
    //                     //               textStyle: TextStyle(
    //                     //                 color: darkPrimaryColor,
    //                     //                 fontSize: 20,
    //                     //               ),
    //                     //             ),
    //                     //           ),
    //                     //           Expanded(
    //                     //             child: Text(
    //                     //               Booking.fromSnapshot(book).info !=
    //                     //                       null
    //                     //                   ? Booking.fromSnapshot(book).info
    //                     //                   : 'No info',
    //                     //               overflow: TextOverflow.ellipsis,
    //                     //               style: GoogleFonts.montserrat(
    //                     //                 textStyle: TextStyle(
    //                     //                   color: darkPrimaryColor,
    //                     //                   fontSize: 20,
    //                     //                 ),
    //                     //               ),
    //                     //             ),
    //                     //           ),
    //                     //           Text(
    //                     //             Booking.fromSnapshot(book).status,
    //                     //             overflow: TextOverflow.ellipsis,
    //                     //             style: GoogleFonts.montserrat(
    //                     //               textStyle: TextStyle(
    //                     //                 color: Booking.fromSnapshot(book)
    //                     //                             .status ==
    //                     //                         'unfinished'
    //                     //                     ? darkPrimaryColor
    //                     //                     : Colors.red,
    //                     //                 fontSize: 20,
    //                     //               ),
    //                     //             ),
    //                     //           ),
    //                     //           SizedBox(
    //                     //             height: size.height * 0.02,
    //                     //           ),
    //                     //           Row(
    //                     //             mainAxisAlignment:
    //                     //                 MainAxisAlignment.center,
    //                     //             children: <Widget>[
    //                     //               RoundedButton(
    //                     //                 width: 0.3,
    //                     //                 height: 0.07,
    //                     //                 text: 'On Map',
    //                     //                 press: () {
    //                     //                   setState(() {
    //                     //                     loading = true;
    //                     //                   });
    //                     //                   Navigator.push(
    //                     //                     context,
    //                     //                     SlideRightRoute(
    //                     //                       page: MapScreen(
    //                     //                         data: {
    //                     //                           'lat': _places != null
    //                     //                               ? _places[Booking
    //                     //                                           .fromSnapshot(
    //                     //                                               book)
    //                     //                                       .id]
    //                     //                                   .lat
    //                     //                               : null,
    //                     //                           'lon': _places != null
    //                     //                               ? _places[Booking
    //                     //                                           .fromSnapshot(
    //                     //                                               book)
    //                     //                                       .id]
    //                     //                                   .lon
    //                     //                               : null
    //                     //                         },
    //                     //                       ),
    //                     //                     ),
    //                     //                   );
    //                     //                   setState(() {
    //                     //                     loading = false;
    //                     //                   });
    //                     //                 },
    //                     //                 color: darkPrimaryColor,
    //                     //                 textColor: whiteColor,
    //                     //               ),
    //                     //               SizedBox(
    //                     //                 width: size.width * 0.04,
    //                     //               ),
    //                     //               RoundedButton(
    //                     //                 width: 0.3,
    //                     //                 height: 0.07,
    //                     //                 text: 'Book',
    //                     //                 press: () async {},
    //                     //                 color: darkPrimaryColor,
    //                     //                 textColor: whiteColor,
    //                     //               ),
    //                     //             ],
    //                     //           ),
    //                     //           SizedBox(
    //                     //             height: size.height * 0.05,
    //                     //           ),
    //                     //         ],
    //                     //       ),
    //                     //     ),
    //                     //   ),
    //                     // )
    //                   ],
    //                 ),
    //               ),
    //             ]
    //           : [
    //               SliverList(
    //                 delegate: SliverChildListDelegate(
    //                   [
    //                     for (var book in _bookings)
    //                       CardW(
    //                         width: 0.8,
    //                         ph: 170,
    //                         child: Column(
    //                           children: [
    //                             SizedBox(
    //                               height: 20,
    //                             ),
    //                             Expanded(
    //                               child: Padding(
    //                                 padding: const EdgeInsets.fromLTRB(
    //                                     10, 0, 10, 0),
    //                                 child: Row(
    //                                   mainAxisAlignment:
    //                                       MainAxisAlignment.start,
    //                                   children: [
    //                                     Container(
    //                                       alignment: Alignment.centerLeft,
    //                                       child: Column(
    //                                         children: [
    //                                           Text(
    //                                             DateFormat.yMMMd()
    //                                                 .format(Booking
    //                                                         .fromSnapshot(
    //                                                             book)
    //                                                     .timestamp_date
    //                                                     .toDate())
    //                                                 .toString(),
    //                                             overflow:
    //                                                 TextOverflow.ellipsis,
    //                                             style:
    //                                                 GoogleFonts.montserrat(
    //                                               textStyle: TextStyle(
    //                                                 color: darkPrimaryColor,
    //                                                 fontSize: 20,
    //                                                 fontWeight:
    //                                                     FontWeight.bold,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                           SizedBox(
    //                                             height: 10,
    //                                           ),
    //                                           Text(
    //                                             Booking.fromSnapshot(book)
    //                                                 .status,
    //                                             overflow:
    //                                                 TextOverflow.ellipsis,
    //                                             style:
    //                                                 GoogleFonts.montserrat(
    //                                               textStyle: TextStyle(
    //                                                 color: Booking.fromSnapshot(
    //                                                                 book)
    //                                                             .status ==
    //                                                         'unfinished'
    //                                                     ? darkPrimaryColor
    //                                                     : Colors.red,
    //                                                 fontSize: 15,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     ),
    //                                     SizedBox(
    //                                       width: size.width * 0.1,
    //                                     ),
    //                                     Flexible(
    //                                       child: Container(
    //                                         alignment: Alignment.centerLeft,
    //                                         child: Column(
    //                                           children: [
    //                                             Text(
    //                                               _places != null
    //                                                   ? _places[Booking.fromSnapshot(
    //                                                                       book)
    //                                                                   .id]
    //                                                               .name !=
    //                                                           null
    //                                                       ? _places[Booking
    //                                                                   .fromSnapshot(
    //                                                                       book)
    //                                                               .id]
    //                                                           .name
    //                                                       : 'Place'
    //                                                   : 'Place',
    //                                               maxLines: 1,
    //                                               overflow:
    //                                                   TextOverflow.ellipsis,
    //                                               style: GoogleFonts
    //                                                   .montserrat(
    //                                                 textStyle: TextStyle(
    //                                                   color:
    //                                                       darkPrimaryColor,
    //                                                   fontSize: 15,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                             SizedBox(
    //                                               height: 10,
    //                                             ),
    //                                             Text(
    //                                               Booking.fromSnapshot(book)
    //                                                       .from +
    //                                                   ' - ' +
    //                                                   Booking.fromSnapshot(
    //                                                           book)
    //                                                       .to,
    //                                               maxLines: 1,
    //                                               overflow:
    //                                                   TextOverflow.ellipsis,
    //                                               style: GoogleFonts
    //                                                   .montserrat(
    //                                                 textStyle: TextStyle(
    //                                                   color:
    //                                                       darkPrimaryColor,
    //                                                   fontSize: 15,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                             ),
    //                             Row(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.center,
    //                               children: <Widget>[
    //                                 RoundedButton(
    //                                   width: 0.3,
    //                                   height: 0.07,
    //                                   text: 'On Map',
    //                                   press: () {},
    //                                   color: darkPrimaryColor,
    //                                   textColor: whiteColor,
    //                                 ),
    //                                 SizedBox(
    //                                   width: size.width * 0.04,
    //                                 ),
    //                                 RoundedButton(
    //                                   width: 0.3,
    //                                   height: 0.07,
    //                                   text: 'Book',
    //                                   press: () {},
    //                                   color: darkPrimaryColor,
    //                                   textColor: whiteColor,
    //                                 ),
    //                                 _places != null
    //                                     ? LabelButton(
    //                                         isC: false,
    //                                         reverse: FirebaseFirestore
    //                                             .instance
    //                                             .collection('users')
    //                                             .doc(FirebaseAuth.instance
    //                                                 .currentUser.uid),
    //                                         containsValue: _places[
    //                                                 Booking.fromSnapshot(
    //                                                         book)
    //                                                     .id]
    //                                             .id,
    //                                         color1: Colors.red,
    //                                         color2: lightPrimaryColor,
    //                                         ph: 45,
    //                                         pw: 45,
    //                                         size: 40,
    //                                         onTap: () {
    //                                           setState(() {
    //                                             FirebaseFirestore.instance
    //                                                 .collection('users')
    //                                                 .doc(FirebaseAuth
    //                                                     .instance
    //                                                     .currentUser
    //                                                     .uid)
    //                                                 .update({
    //                                               'favourites': FieldValue
    //                                                   .arrayUnion([
    //                                                 _places[Booking
    //                                                             .fromSnapshot(
    //                                                                 book)
    //                                                         .id]
    //                                                     .id
    //                                               ])
    //                                             });
    //                                           });
    //                                         },
    //                                         onTap2: () {
    //                                           setState(() {
    //                                             FirebaseFirestore.instance
    //                                                 .collection('users')
    //                                                 .doc(FirebaseAuth
    //                                                     .instance
    //                                                     .currentUser
    //                                                     .uid)
    //                                                 .update({
    //                                               'favourites': FieldValue
    //                                                   .arrayRemove([
    //                                                 _places[Booking
    //                                                             .fromSnapshot(
    //                                                                 book)
    //                                                         .id]
    //                                                     .id
    //                                               ])
    //                                             });
    //                                           });
    //                                         },
    //                                       )
    //                                     : Container(),
    //                               ],
    //                             ),
    //                             SizedBox(
    //                               height: 20,
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                   ],
    //                 ),
    //               ),
    //             ],
    //     ),
    //   );
  }
}
