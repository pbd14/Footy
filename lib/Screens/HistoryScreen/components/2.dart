import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Booking.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Models/PushNotificationMessage.dart';
import 'package:flutter_complete_guide/Screens/HomeScreen/home_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/label_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';

class History2 extends StatefulWidget {
  @override
  _History2State createState() => _History2State();
}

class _History2State extends State<History2>
    with AutomaticKeepAliveClientMixin<History2> {
  @override
  bool get wantKeepAlive => true;
  bool loading = false;
  List _bookings = [];
  Map _places = {};
  StreamSubscription<QuerySnapshot> ordinaryPlacesSubscr;

  @override
  void dispose() {
    ordinaryPlacesSubscr.cancel();
    super.dispose();
  }

  Future<void> ordinaryBookPrep(
      List<QueryDocumentSnapshot> _unrbookings1) async {
    DocumentSnapshot customUB;
    if (_unrbookings1.length != 0) {
      for (QueryDocumentSnapshot book in _bookings) {
        DocumentSnapshot data1 = await FirebaseFirestore.instance
            .collection('locations')
            .doc(Booking.fromSnapshot(book).placeId)
            .get();
        setState(() {
          _places.addAll({
            Booking.fromSnapshot(book).id: Place.fromSnapshot(data1),
          });
        });
      }
    }
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
    });
    ordinaryPlacesSubscr = FirebaseFirestore.instance
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
        .limit(20)
        .snapshots()
        .listen((bookings) async {
      setState(() {
        _bookings = bookings.docs;
        ordinaryBookPrep(bookings.docs);
      });
    });
    setState(() {
      loading = false;
    });
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    _bookings = [];
    _places = {};
    loadData();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
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
        : RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              scrollDirection: Axis.vertical,
              slivers: [
                _bookings != null
                    ? SliverList(
                        delegate: SliverChildListDelegate([
                          for (var book in _bookings)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10.0),
                              // padding: EdgeInsets.all(10),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
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
                                                _places[Booking.fromSnapshot(
                                                                book)
                                                            .id] !=
                                                        null
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
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      color:
                                                          Booking.fromSnapshot(
                                                                          book)
                                                                      .status ==
                                                                  'unfinished'
                                                              ? darkColor
                                                              : Colors.red,
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
                                                                .lat,
                                                            'lon': _places[Booking
                                                                        .fromSnapshot(
                                                                            book)
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
                          // CardW(
                          //   ph: 170,
                          //   child: Container(
                          //     padding: EdgeInsets.all(6),
                          //     child: Column(
                          //       children: [
                          //         SizedBox(
                          //           height: 20,
                          //         ),
                          //         Expanded(
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
                          //                           .format(
                          //                               Booking.fromSnapshot(
                          //                                       book)
                          //                                   .timestamp_date
                          //                                   .toDate())
                          //                           .toString(),
                          //                       overflow:
                          //                           TextOverflow.ellipsis,
                          //                       style: GoogleFonts.montserrat(
                          //                         textStyle: TextStyle(
                          //                           color: darkPrimaryColor,
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
                          //                           .status,
                          //                       overflow:
                          //                           TextOverflow.ellipsis,
                          //                       style: GoogleFonts.montserrat(
                          //                         textStyle: TextStyle(
                          //                           color:
                          //                               Booking.fromSnapshot(
                          //                                               book)
                          //                                           .status ==
                          //                                       'unfinished'
                          //                                   ? darkPrimaryColor
                          //                                   : Colors.red,
                          //                           fontSize: 15,
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ),
                          //               SizedBox(
                          //                 width: size.width * 0.2,
                          //               ),
                          //               Flexible(
                          //                 child: Container(
                          //                   alignment: Alignment.centerLeft,
                          //                   child: Column(
                          //                     children: [
                          //                       Text(
                          //                         _places != null
                          //                             ? _places[Booking.fromSnapshot(
                          //                                                 book)
                          //                                             .id]
                          //                                         .name !=
                          //                                     null
                          //                                 ? _places[Booking
                          //                                             .fromSnapshot(
                          //                                                 book)
                          //                                         .id]
                          //                                     .name
                          //                                 : 'Place'
                          //                             : 'Place',
                          //                         overflow:
                          //                             TextOverflow.ellipsis,
                          //                         style:
                          //                             GoogleFonts.montserrat(
                          //                           textStyle: TextStyle(
                          //                             color: darkPrimaryColor,
                          //                             fontSize: 20,
                          //                           ),
                          //                         ),
                          //                       ),
                          //                       SizedBox(
                          //                         height: 10,
                          //                       ),
                          //                       Text(
                          //                         Booking.fromSnapshot(book)
                          //                                 .from +
                          //                             ' - ' +
                          //                             Booking.fromSnapshot(
                          //                                     book)
                          //                                 .to,
                          //                         overflow:
                          //                             TextOverflow.ellipsis,
                          //                         style:
                          //                             GoogleFonts.montserrat(
                          //                           textStyle: TextStyle(
                          //                             color: darkPrimaryColor,
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
                          //         Row(
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.center,
                          //           children: <Widget>[
                          //             RoundedButton(
                          //               width: 0.3,
                          //               height: 0.07,
                          //               text: 'On Map',
                          //               press: () {
                          //                 setState(() {
                          //                   loading = true;
                          //                 });
                          //                 Navigator.push(
                          //                   context,
                          //                   SlideRightRoute(
                          //                     page: MapScreen(
                          //                       data: {
                          //                         'lat': _places[Booking
                          //                                     .fromSnapshot(
                          //                                         book)
                          //                                 .id]
                          //                             .lat,
                          //                         'lon': _places[Booking
                          //                                     .fromSnapshot(
                          //                                         book)
                          //                                 .id]
                          //                             .lon
                          //                       },
                          //                     ),
                          //                   ),
                          //                 );
                          //                 setState(() {
                          //                   loading = false;
                          //                 });
                          //               },
                          //               color: darkPrimaryColor,
                          //               textColor: whiteColor,
                          //             ),
                          //             SizedBox(
                          //               width: size.width * 0.04,
                          //             ),
                          //             _places != null
                          //                 ? LabelButton(
                          //                     isC: false,
                          //                     reverse: FirebaseFirestore
                          //                         .instance
                          //                         .collection('users')
                          //                         .doc(FirebaseAuth.instance
                          //                             .currentUser.uid),
                          //                     containsValue: _places[
                          //                             Booking.fromSnapshot(
                          //                                     book)
                          //                                 .id]
                          //                         .id,
                          //                     color1: Colors.red,
                          //                     color2: lightPrimaryColor,
                          //                     ph: 45,
                          //                     pw: 45,
                          //                     size: 40,
                          //                     onTap: () {
                          //                       setState(() {
                          //                         FirebaseFirestore.instance
                          //                             .collection('users')
                          //                             .doc(FirebaseAuth
                          //                                 .instance
                          //                                 .currentUser
                          //                                 .uid)
                          //                             .update({
                          //                           'favourites': FieldValue
                          //                               .arrayUnion([
                          //                             _places[Booking
                          //                                         .fromSnapshot(
                          //                                             book)
                          //                                     .id]
                          //                                 .id
                          //                           ])
                          //                         });
                          //                       });
                          //                       ScaffoldMessenger.of(context)
                          //                           .showSnackBar(
                          //                         SnackBar(
                          //                           duration:
                          //                               Duration(seconds: 2),
                          //                           backgroundColor:
                          //                               darkPrimaryColor,
                          //                           content: Text(
                          //                             'Saved to favourites',
                          //                             style: GoogleFonts
                          //                                 .montserrat(
                          //                               textStyle: TextStyle(
                          //                                 color: whiteColor,
                          //                                 fontSize: 15,
                          //                               ),
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       );
                          //                     },
                          //                     onTap2: () {
                          //                       setState(() {
                          //                         FirebaseFirestore.instance
                          //                             .collection('users')
                          //                             .doc(FirebaseAuth
                          //                                 .instance
                          //                                 .currentUser
                          //                                 .uid)
                          //                             .update({
                          //                           'favourites': FieldValue
                          //                               .arrayRemove([
                          //                             _places[Booking
                          //                                         .fromSnapshot(
                          //                                             book)
                          //                                     .id]
                          //                                 .id
                          //                           ])
                          //                         });
                          //                       });
                          //                       ScaffoldMessenger.of(context)
                          //                           .showSnackBar(
                          //                         SnackBar(
                          //                           duration:
                          //                               Duration(seconds: 2),
                          //                           backgroundColor:
                          //                               Colors.red,
                          //                           content: Text(
                          //                             'Removed from favourites',
                          //                             style: GoogleFonts
                          //                                 .montserrat(
                          //                               textStyle: TextStyle(
                          //                                 color: whiteColor,
                          //                                 fontSize: 15,
                          //                               ),
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       );
                          //                     },
                          //                   )
                          //                 : Container(),
                          //           ],
                          //         ),
                          //         SizedBox(
                          //           height: 20,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ]),
                      )
                    : SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No history',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: darkPrimaryColor,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          );

    // Container(
    //   alignment: Alignment.center,
    //   child: Column(
    //     children: <Widget>[
    //       _bookings != null
    //           ? ListView.builder(
    //               scrollDirection: Axis.vertical,
    //               shrinkWrap: true,
    //               itemCount: _bookings.length,
    //               itemBuilder: (BuildContext context, int index) => CardW(
    //                 ph: 170,
    //                 child: Column(
    //                   children: [
    //                     SizedBox(
    //                       height: 20,
    //                     ),
    //                     Expanded(
    //                       child: Row(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         children: [
    //                           Container(
    //                             alignment: Alignment.centerLeft,
    //                             child: Column(
    //                               children: [
    //                                 Text(
    //                                   DateFormat.yMMMd()
    //                                       .format(Booking.fromSnapshot(
    //                                               _bookings[index])
    //                                           .timestamp_date
    //                                           .toDate())
    //                                       .toString(),
    //                                   overflow: TextOverflow.ellipsis,
    //                                   style: GoogleFonts.montserrat(
    //                                     textStyle: TextStyle(
    //                                       color: darkPrimaryColor,
    //                                       fontSize: 20,
    //                                       fontWeight: FontWeight.bold,
    //                                     ),
    //                                   ),
    //                                 ),
    //                                 SizedBox(
    //                                   height: 10,
    //                                 ),
    //                                 Text(
    //                                   Booking.fromSnapshot(_bookings[index])
    //                                       .status,
    //                                   overflow: TextOverflow.ellipsis,
    //                                   style: GoogleFonts.montserrat(
    //                                     textStyle: TextStyle(
    //                                       color: Booking.fromSnapshot(
    //                                                       _bookings[index])
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
    //                             width: size.width * 0.2,
    //                           ),
    //                           Flexible(
    //                             child: Container(
    //                               alignment: Alignment.centerLeft,
    //                               child: Column(
    //                                 children: [
    //                                   Text(
    //                                     _places != null
    //                                         ? _places[Booking.fromSnapshot(
    //                                                             _bookings[
    //                                                                 index])
    //                                                         .id]
    //                                                     .name !=
    //                                                 null
    //                                             ? _places[Booking.fromSnapshot(
    //                                                         _bookings[index])
    //                                                     .id]
    //                                                 .name
    //                                             : 'Place'
    //                                         : 'Place',
    //                                     overflow: TextOverflow.ellipsis,
    //                                     style: GoogleFonts.montserrat(
    //                                       textStyle: TextStyle(
    //                                         color: darkPrimaryColor,
    //                                         fontSize: 20,
    //                                       ),
    //                                     ),
    //                                   ),
    //                                   SizedBox(
    //                                     height: 10,
    //                                   ),
    //                                   Text(
    //                                     Booking.fromSnapshot(_bookings[index])
    //                                             .from +
    //                                         ' - ' +
    //                                         Booking.fromSnapshot(
    //                                                 _bookings[index])
    //                                             .to,
    //                                     overflow: TextOverflow.ellipsis,
    //                                     style: GoogleFonts.montserrat(
    //                                       textStyle: TextStyle(
    //                                         color: darkPrimaryColor,
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
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: <Widget>[
    //                         RoundedButton(
    //                           width: 0.3,
    //                           height: 0.07,
    //                           text: 'On Map',
    //                           press: () {
    //                             setState(() {
    //                               loading = true;
    //                             });
    //                             Navigator.push(
    //                               context,
    //                               SlideRightRoute(
    //                                 page: MapScreen(
    //                                   data: {
    //                                     'lat': _places[Booking.fromSnapshot(
    //                                                 _bookings[index])
    //                                             .id]
    //                                         .lat,
    //                                     'lon': _places[Booking.fromSnapshot(
    //                                                 _bookings[index])
    //                                             .id]
    //                                         .lon
    //                                   },
    //                                 ),
    //                               ),
    //                             );
    //                             setState(() {
    //                               loading = false;
    //                             });
    //                           },
    //                           color: darkPrimaryColor,
    //                           textColor: whiteColor,
    //                         ),
    //                         SizedBox(
    //                           width: size.width * 0.04,
    //                         ),
    //                         _places != null
    //                             ? LabelButton(
    //                                 isC: false,
    //                                 reverse: FirebaseFirestore.instance
    //                                     .collection('users')
    //                                     .doc(FirebaseAuth
    //                                         .instance.currentUser.uid),
    //                                 containsValue: _places[Booking.fromSnapshot(
    //                                             _bookings[index])
    //                                         .id]
    //                                     .id,
    //                                 color1: Colors.red,
    //                                 color2: lightPrimaryColor,
    //                                 ph: 45,
    //                                 pw: 45,
    //                                 size: 40,
    //                                 onTap: () {
    //                                   setState(() {
    //                                     FirebaseFirestore.instance
    //                                         .collection('users')
    //                                         .doc(FirebaseAuth
    //                                             .instance.currentUser.uid)
    //                                         .update({
    //                                       'favourites': FieldValue.arrayUnion([
    //                                         _places[Booking.fromSnapshot(
    //                                                     _bookings[index])
    //                                                 .id]
    //                                             .id
    //                                       ])
    //                                     });
    //                                   });
    //                                 },
    //                                 onTap2: () {
    //                                   setState(() {
    //                                     FirebaseFirestore.instance
    //                                         .collection('users')
    //                                         .doc(FirebaseAuth
    //                                             .instance.currentUser.uid)
    //                                         .update({
    //                                       'favourites': FieldValue.arrayRemove([
    //                                         _places[Booking.fromSnapshot(
    //                                                     _bookings[index])
    //                                                 .id]
    //                                             .id
    //                                       ])
    //                                     });
    //                                   });
    //                                 },
    //                               )
    //                             : Container(),
    //                       ],
    //                     ),
    //                     SizedBox(
    //                       height: 20,
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             )
    //           : Container(),
    //     ],
    //   ),
    // );
  }
}
