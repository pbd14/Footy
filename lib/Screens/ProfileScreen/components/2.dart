import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Screens/HomeScreen/home_screen.dart';
import 'package:flutter_complete_guide/Screens/MapScreen/map_screen.dart';
import 'package:flutter_complete_guide/Screens/PlaceScreen/place_screen.dart';
import 'package:flutter_complete_guide/Screens/ProfileScreen/components/settings.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/Services/auth_service.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/label_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen2 extends StatefulWidget {
  @override
  _ProfileScreen2State createState() => _ProfileScreen2State();
}

class _ProfileScreen2State extends State<ProfileScreen2>
    with AutomaticKeepAliveClientMixin<ProfileScreen2> {
  @override
  bool get wantKeepAlive => true;
  bool loading = false;
  List _favs = [];
  List _places = [];

  Future<void> loadData() async {
    setState(() {
      loading = true;
    });
    DocumentSnapshot dataL = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    setState(() {
      _favs = dataL.data()['favourites'];
    });
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('locations')
        .orderBy('name')
        .get();
    for (QueryDocumentSnapshot doc in data.docs) {
      if (_favs != null) {
        if (_favs.contains(doc.reference.id.toString())) {
          _places.add(doc);
        }
      }
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

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    _favs = [];
    _places = [];
    loadData();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: size.width * 0.17,
                backgroundColor: whiteColor,
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(CupertinoIcons.gear),
                    onPressed: () {
                      setState(() {
                        loading = true;
                      });
                      Navigator.push(
                          context,
                          SlideRightRoute(
                            page: SettingsScreen(),
                          ));
                      setState(() {
                        loading = false;
                      });
                    },
                  ),
                  IconButton(
                    color: darkColor,
                    icon: Icon(
                      Icons.exit_to_app,
                    ),
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Выйти?'),
                            content:
                                const Text('Хотите ли вы выйти из аккаунта?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  // prefs.setBool('local_auth', false);
                                  // prefs.setString('local_password', '');
                                  Navigator.of(context).pop(true);
                                  AuthService().signOut(context);
                                },
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(color: primaryColor),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text(
                                  'No',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ]),
            body: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(scrollDirection: Axis.vertical, slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                FirebaseAuth.instance.currentUser.phoneNumber
                                    .toString(),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: darkColor,
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
                _places != null
                    ? SliverList(
                        delegate: SliverChildListDelegate([
                          for (var place in _places)
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: size.width * 0.45,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                Place.fromSnapshot(place).name,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                Place.fromSnapshot(place).by !=
                                                        null
                                                    ? Place.fromSnapshot(place)
                                                        .by
                                                    : 'No company',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      color: darkPrimaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            width: size.width * 0.35,
                                            child: Row(
                                              children: [
                                                _places != null
                                                    ? Container(
                                                        width: 30,
                                                        child: LabelButton(
                                                          isC: false,
                                                          reverse: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(FirebaseAuth
                                                                  .instance
                                                                  .currentUser
                                                                  .uid),
                                                          containsValue: Place
                                                                  .fromSnapshot(
                                                                      place)
                                                              .id,
                                                          color1: Colors.red,
                                                          color2:
                                                              lightPrimaryColor,
                                                          size: 24,
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
                                                                  Place.fromSnapshot(
                                                                          place)
                                                                      .id
                                                                ])
                                                              });
                                                            });
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
                                                                  Place.fromSnapshot(
                                                                          place)
                                                                      .id
                                                                ])
                                                              });
                                                            });
                                                          },
                                                        ),
                                                      )
                                                    : Container(),
                                                IconButton(
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
                                                            'lat': Place
                                                                    .fromSnapshot(
                                                                        place)
                                                                .lat,
                                                            'lon': Place
                                                                    .fromSnapshot(
                                                                        place)
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
                                                IconButton(
                                                  icon: Icon(
                                                    CupertinoIcons.book,
                                                    color: darkPrimaryColor,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      loading = true;
                                                    });
                                                    Navigator.push(
                                                      context,
                                                      SlideRightRoute(
                                                        page: PlaceScreen(
                                                          placeId: place.id,
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
                        ]),
                      )
                    : Center(
                        child: Text(
                          'No favourites',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkPrimaryColor,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
              ]),
            ),
          );

    // Container(
    //   alignment: Alignment.center,
    //   child: Column(
    //     children: <Widget>[
    //       _places != null
    //           ? ListView.builder(
    //               scrollDirection: Axis.vertical,
    //               shrinkWrap: true,
    //               itemCount: _places.length,
    //               itemBuilder: (BuildContext context, int index) => CardW(
    //                 ph: 170,
    //                 child: Column(
    //                   children: [
    //                     SizedBox(
    //                       height: 20,
    //                     ),
    //                     Expanded(
    //                       child: Padding(
    //                         padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
    //                         child: Row(
    //                           mainAxisAlignment: MainAxisAlignment.center,
    //                           children: [
    //                             Container(
    //                               alignment: Alignment.centerLeft,
    //                               child: Column(
    //                                 children: [
    //                                   Text(
    //                                     Place.fromSnapshot(_places[index])
    //                                         .name
    //                                         .toString(),
    //                                     overflow: TextOverflow.ellipsis,
    //                                     style: GoogleFonts.montserrat(
    //                                       textStyle: TextStyle(
    //                                         color: darkPrimaryColor,
    //                                         fontSize: 20,
    //                                         fontWeight: FontWeight.bold,
    //                                       ),
    //                                     ),
    //                                   ),
    //                                   SizedBox(
    //                                     height: 10,
    //                                   ),
    //                                   Text(
    //                                     Place.fromSnapshot(_places[index]).by !=
    //                                             null
    //                                         ? Place.fromSnapshot(_places[index])
    //                                             .by
    //                                         : 'No info',
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
    //                             SizedBox(
    //                               width: size.width * 0.2,
    //                             ),
    //                             Flexible(
    //                               child: Container(
    //                                 alignment: Alignment.centerLeft,
    //                                 child: Column(
    //                                   children: [
    //                                     Text(
    //                                       Place.fromSnapshot(_places[index])
    //                                                   .description !=
    //                                               null
    //                                           ? Place.fromSnapshot(
    //                                                   _places[index])
    //                                               .description
    //                                           : 'No description',
    //                                       overflow: TextOverflow.ellipsis,
    //                                       style: GoogleFonts.montserrat(
    //                                         textStyle: TextStyle(
    //                                           color: darkPrimaryColor,
    //                                           fontSize: 20,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                     SizedBox(
    //                                       height: 10,
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: <Widget>[
    //                         RoundedButton(
    //                           width: 0.3,
    //                           height: 0.07,
    //                           text: 'On Map',
    //                           press: () async {
    //                             setState(() {
    //                               loading = true;
    //                             });
    //                             Navigator.push(
    //                               context,
    //                               SlideRightRoute(
    //                                 page: MapScreen(
    //                                   data: {
    //                                     'lat':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .lat,
    //                                     'lon':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .lon
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
    //                         RoundedButton(
    //                           width: 0.3,
    //                           height: 0.07,
    //                           text: 'Book',
    //                           press: () async {
    //                             setState(() {
    //                               loading = true;
    //                             });
    //                             Navigator.push(
    //                               context,
    //                               SlideRightRoute(
    //                                 page: PlaceScreen(
    //                                   data: {
    //                                     'name':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .name, //0
    //                                     'description':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .description, //1
    //                                     'by': Place.fromSnapshot(_places[index])
    //                                         .by, //2
    //                                     'lat':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .lat, //3
    //                                     'lon':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .lon, //4
    //                                     'images':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .images, //5
    //                                     'services':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .services,
    //                                     'id': Place.fromSnapshot(_places[index])
    //                                         .id, //7
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
    //                           width: 7,
    //                         ),
    //                         _places != null
    //                             ? LabelButton(
    //                                 isC: false,
    //                                 reverse: FirebaseFirestore.instance
    //                                     .collection('users')
    //                                     .doc(FirebaseAuth
    //                                         .instance.currentUser.uid),
    //                                 containsValue:
    //                                     Place.fromSnapshot(_places[index]).id,
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
    //                                         Place.fromSnapshot(_places[index])
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
    //                                         Place.fromSnapshot(_places[index])
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
