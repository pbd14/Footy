import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Screens/OnEventScreen/on_event_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/card.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';

class FootyScreen extends StatefulWidget {
  @override
  _FootyScreenState createState() => _FootyScreenState();
}

class _FootyScreenState extends State<FootyScreen> {
  bool loading = false;
  List slivers = [];
  List<Widget> sliversList = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: CustomScrollView(
              scrollDirection: Axis.vertical,
              slivers: slivers.length != 0
                  ? [
                      SliverGrid.count(
                        children: [
                          for (var book in slivers)
                            FlatButton(
                              padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
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
                                alignment: Alignment.center,
                                color: darkPrimaryColor,
                                child: Text('Place',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: whiteColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                        crossAxisCount: 2,
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            CardW(
                              width: 0.8,
                              height: 0.45,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 15, 0),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: size.height * 0.04,
                                      ),
                                      Text(
                                        '31 January',
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
                                        '12:00' + ' - ' + '14:00',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkPrimaryColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
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
                                      Expanded(
                                        child: Text(
                                          'No info',
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
                                        'unfinished',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkPrimaryColor,
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
                                        height: size.height * 0.05,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ]
                  : [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
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
                                                  '31 January',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: darkPrimaryColor,
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
                                                  'unfinished',
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
                                                  '12:00' + ' - ' + '14:00',
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
                              // Center(
                              //   child: Padding(
                              //     padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              //     child: Column(
                              //       children: <Widget>[
                              //         SizedBox(
                              //           height: 20,
                              //         ),
                              //         Text(
                              //           '31 January',
                              //           overflow: TextOverflow.ellipsis,
                              //           style: GoogleFonts.montserrat(
                              //             textStyle: TextStyle(
                              //               color: darkPrimaryColor,
                              //               fontSize: 20,
                              //               fontWeight: FontWeight.bold,
                              //             ),
                              //           ),
                              //         ),
                              //         SizedBox(
                              //           height: 10,
                              //         ),
                              //         Text(
                              //           '12:00' + ' - ' + '14:00',
                              //           overflow: TextOverflow.ellipsis,
                              //           style: GoogleFonts.montserrat(
                              //             textStyle: TextStyle(
                              //               color: darkPrimaryColor,
                              //               fontSize: 15,
                              //             ),
                              //           ),
                              //         ),
                              //         SizedBox(
                              //           height: 10,
                              //         ),
                              //         Text(
                              //           // _places != null
                              //           //     ? _places[Booking.fromSnapshot(book)
                              //           //                     .id]
                              //           //                 .name !=
                              //           //             null
                              //           //         ? _places[Booking.fromSnapshot(
                              //           //                     book)
                              //           //                 .id]
                              //           //             .name
                              //           //         : 'Place'
                              //           //     : 'Place',
                              //           'Place',
                              //           overflow: TextOverflow.ellipsis,
                              //           style: GoogleFonts.montserrat(
                              //             textStyle: TextStyle(
                              //               color: darkPrimaryColor,
                              //               fontSize: 20,
                              //             ),
                              //           ),
                              //         ),
                              //         SizedBox(
                              //           height: 10,
                              //         ),
                              //         Text(
                              //           'No info',
                              //           overflow: TextOverflow.ellipsis,
                              //           style: GoogleFonts.montserrat(
                              //             textStyle: TextStyle(
                              //               color: darkPrimaryColor,
                              //               fontSize: 15,
                              //             ),
                              //           ),
                              //         ),
                              //         Text(
                              //           'unfinished',
                              //           overflow: TextOverflow.ellipsis,
                              //           style: GoogleFonts.montserrat(
                              //             textStyle: TextStyle(
                              //               color: darkPrimaryColor,
                              //               fontSize: 15,
                              //             ),
                              //           ),
                              //         ),
                              //         SizedBox(
                              //           height: 20,
                              //         ),
                              //         Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.center,
                              //           children: <Widget>[
                              //             RoundedButton(
                              //               width: 0.3,
                              //               height: 0.07,
                              //               text: 'On Map',
                              //               press: () {},
                              //               color: darkPrimaryColor,
                              //               textColor: whiteColor,
                              //             ),
                              //             SizedBox(
                              //               width: size.width * 0.04,
                              //             ),
                              //             RoundedButton(
                              //               width: 0.3,
                              //               height: 0.07,
                              //               text: 'Book',
                              //               press: () {},
                              //               color: darkPrimaryColor,
                              //               textColor: whiteColor,
                              //             ),
                              //           ],
                              //         ),
                              //         SizedBox(
                              //           height: size.height * 0.05,
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ),
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
                                                  '31 January',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: darkPrimaryColor,
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
                                                  'unfinished',
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
                                                  '12:00' + ' - ' + '14:00',
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
                          ],
                        ),
                      ),
                    ],
            ),
          );
  }
}

// import 'dart:async';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_complete_guide/Services/auth_service.dart';
// import 'package:flutter_complete_guide/constants.dart';

// class FootyScreen extends StatefulWidget {
//   @override
//   _FootyScreenState createState() => _FootyScreenState();
// }

// // class _FootyScreenState extends State<FootyScreen> {
// //   Future<Widget> loadFromFuture() async {
// //     await Firebase.initializeApp();
// //     return Future.value(AuthService().handleAuth());
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     Size size = MediaQuery.of(context).size;
// //     return SplashScreen(
// //       navigateAfterFuture: loadFromFuture(),
// //       image: Image.asset(
// //         'assets/images/Footy.png',
// //         width: 1 * size.width,
// //       ),
// //       photoSize: 100.0,
// //       backgroundColor: Colors.white,
// //       useLoader: false,
// //     );
// //   }
// // }

// bool isOnEvent = false;

// class _FootyScreenState extends State<FootyScreen> {
//   @override
//   void initState() {
//     Timer(Duration(seconds: 2), () async {
//       await Firebase.initializeApp();
//       Navigator.pushReplacement(context,
//           MaterialPageRoute(builder: (context) => AuthService().handleAuth()));
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: AnimatedContainer(
//         curve: Curves.fastOutSlowIn,
//         duration: const Duration(milliseconds: 100),
//         color: whiteColor,
//         child: Center(
//           child: Image.asset(
//             'assets/images/Footy.png',
//             width: 1 * size.width,
//           ),
//         ),
//       ),
//     );
//   }
// }
