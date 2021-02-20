import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class ProfileScreen2 extends StatefulWidget {
  @override
  _ProfileScreen2State createState() => _ProfileScreen2State();
}

class _ProfileScreen2State extends State<ProfileScreen2> {
  bool loading = false;
  List _favs = [];
  List _places = [];

  Future<void> loadData() async {
    setState(() {
      loading = true;
    });
    var dataL = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    setState(() {
      _favs = dataL.data()['favourites'];
    });
    var data = await FirebaseFirestore.instance
        .collection('locations')
        .orderBy('name')
        .get();
    for (var doc in data.docs) {
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : CustomScrollView(scrollDirection: Axis.vertical, slivers: [
            _places != null
                ? SliverList(
                    delegate: SliverChildListDelegate([
                      for (var place in _places)
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
                                              Place.fromSnapshot(place)
                                                  .name
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
                                              Place.fromSnapshot(place).by !=
                                                      null
                                                  ? Place.fromSnapshot(place).by
                                                  : 'No info',
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
                                      SizedBox(
                                        width: size.width * 0.2,
                                      ),
                                      Flexible(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            children: [
                                              Text(
                                                Place.fromSnapshot(place)
                                                            .description !=
                                                        null
                                                    ? Place.fromSnapshot(place)
                                                        .description
                                                    : 'No description',
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
                                    press: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: MapScreen(
                                            data: {
                                              'lat':
                                                  Place.fromSnapshot(place).lat,
                                              'lon':
                                                  Place.fromSnapshot(place).lon
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
                                    press: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: PlaceScreen(
                                            data: {
                                              'name': Place.fromSnapshot(place)
                                                  .name, //0
                                              'description':
                                                  Place.fromSnapshot(place)
                                                      .description, //1
                                              'by': Place.fromSnapshot(place)
                                                  .by, //2
                                              'lat': Place.fromSnapshot(place)
                                                  .lat, //3
                                              'lon': Place.fromSnapshot(place)
                                                  .lon, //4
                                              'images':
                                                  Place.fromSnapshot(place)
                                                      .images, //5
                                              'services':
                                                  Place.fromSnapshot(place)
                                                      .services,
                                              'id': Place.fromSnapshot(place)
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
                                  SizedBox(
                                    width: 7,
                                  ),
                                  _places != null
                                      ? LabelButton(
                                          isC: false,
                                          reverse: FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser.uid),
                                          containsValue:
                                              Place.fromSnapshot(place).id,
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
                                                  Place.fromSnapshot(place).id
                                                ])
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
                                                  Place.fromSnapshot(place).id
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
          ]);

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
