import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Screens/MapScreen/map_screen.dart';
import 'package:flutter_complete_guide/Screens/PlaceScreen/place_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/Screens/SearchScreen/components/background.dart';
import 'package:flutter_complete_guide/widgets/card.dart';
import 'package:flutter_complete_guide/widgets/label_button.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:flutter_complete_guide/widgets/rounded_text_input.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();

  List _allResults = [];
  List _results = [];

  Future resultsLoaded;

  bool loading = false;
  bool loading1 = false;

  TextEditingController _searchController = TextEditingController();

  getPlaces() async {
    setState(() {
      loading1 = true;
    });
    var data = await FirebaseFirestore.instance
        .collection('locations')
        .orderBy('name')
        .get();
    setState(() {
      _allResults = data.docs;
    });
    search();
    return 'Complete';
  }

  search() {
    var showResults = [];
    if (_searchController.text != '') {
      for (var placeSnapshot in _allResults) {
        var name = Place.fromSnapshot(placeSnapshot).name.toLowerCase();
        if (name.contains(_searchController.text.toLowerCase())) {
          showResults.add(placeSnapshot);
        }
      }
    } else {
      showResults = _allResults;
    }
    setState(() {
      _results = showResults;
      loading1 = false;
    });
  }

  _onSearchChanged() {
    search();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resultsLoaded = getPlaces();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: whiteColor,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Background(
                  child: Form(
                    key: _formKey,
                    child: Container(
                      width: size.width * 0.85,
                      margin: EdgeInsets.fromLTRB(
                          size.width * 0.065,
                          size.height * 0.01,
                          size.width * 0.065,
                          size.height * 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RoundedTextInput(
                            controller: _searchController,
                            icon: Icons.search,
                            hintText: 'Place name',
                            type: TextInputType.text,
                          ),
                          Expanded(
                            child: loading1
                                ? LoadingScreen()
                                : Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    child: ListView.builder(
                                      itemCount: _results.length,
                                      itemBuilder:
                                          (BuildContext context, int index) =>
                                              CardW(
                                        width: 0.8,
                                        ph: 250,
                                        child: Center(
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                20, 0, 15, 0),
                                            child: Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: size.height * 0.04,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: size.width * 0.03,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        Place.fromSnapshot(
                                                                _results[index])
                                                            .name,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color:
                                                                darkPrimaryColor,
                                                            fontSize: 25,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    LabelButton(
                                                      color1: Colors.red,
                                                      color2: lightPrimaryColor,
                                                      ph: 45,
                                                      pw: 45,
                                                      size: 40,
                                                      onTap: () async {
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
                                                            'favourites': Place
                                                                    .fromSnapshot(
                                                                        _results[
                                                                            index])
                                                                .id
                                                          });
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.03,
                                                ),
                                                Text(
                                                  Place.fromSnapshot(_results[
                                                                  index])
                                                              .description !=
                                                          null
                                                      ? Place.fromSnapshot(
                                                              _results[index])
                                                          .description
                                                      : 'No description',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: darkPrimaryColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.01,
                                                ),
                                                Text(
                                                  Place.fromSnapshot(_results[
                                                                  index])
                                                              .by !=
                                                          null
                                                      ? Place.fromSnapshot(
                                                              _results[index])
                                                          .by
                                                      : 'No company',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: darkPrimaryColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.04,
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
                                                            page: MapScreen(
                                                              data: {
                                                                'lat': Place.fromSnapshot(
                                                                        _results[
                                                                            index])
                                                                    .lat,
                                                                'lon': Place.fromSnapshot(
                                                                        _results[
                                                                            index])
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
                                                      press: () async {
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        Navigator.push(
                                                          context,
                                                          SlideRightRoute(
                                                            page: PlaceScreen(
                                                              data: {
                                                                'name': Place.fromSnapshot(
                                                                        _results[
                                                                            index])
                                                                    .name, //0
                                                                'description': Place
                                                                        .fromSnapshot(
                                                                            _results[index])
                                                                    .description, //1
                                                                'by': Place.fromSnapshot(
                                                                        _results[
                                                                            index])
                                                                    .by, //2
                                                                'lat': Place.fromSnapshot(
                                                                        _results[
                                                                            index])
                                                                    .lat, //3
                                                                'lon': Place.fromSnapshot(
                                                                        _results[
                                                                            index])
                                                                    .lon, //4
                                                                'images': Place.fromSnapshot(
                                                                        _results[
                                                                            index])
                                                                    .images, //5
                                                                'services': Place
                                                                        .fromSnapshot(
                                                                            _results[index])
                                                                    .services,
                                                                'id': Place.fromSnapshot(
                                                                        _results[
                                                                            index])
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
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            // StreamBuilder(
                            //   stream: FirebaseFirestore.instance
                            //       .collection('locations')
                            //       .orderBy('name')
                            //       .limit(100)
                            //       .snapshots(),
                            //   builder: (context, snapshot) {
                            //     return !snapshot.hasData
                            //         ? LoadingScreen()
                            //         : Padding(
                            //             padding: const EdgeInsets.fromLTRB(
                            //                 0, 5, 0, 5),
                            //             child: ListView.builder(
                            //               itemCount:
                            //                   snapshot.data.documents.length,
                            //               itemBuilder: (context, index) {
                            //                 DocumentSnapshot places =
                            //                     snapshot.data.documents[index];
                            //                 return CardW(
                            //                   width: 0.7,
                            //                   height: 0.35,
                            //                   child: Center(
                            //                     child: Padding(
                            //                       padding: EdgeInsets.fromLTRB(
                            //                           20, 0, 15, 0),
                            //                       child: Column(
                            //                         children: <Widget>[
                            //                           SizedBox(
                            //                             height:
                            //                                 size.height * 0.04,
                            //                           ),
                            //                           Text(
                            //                             places.data()['name'],
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: GoogleFonts
                            //                                 .montserrat(
                            //                               textStyle: TextStyle(
                            //                                 color:
                            //                                     darkPrimaryColor,
                            //                                 fontSize: 25,
                            //                                 fontWeight:
                            //                                     FontWeight.bold,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                           SizedBox(
                            //                             height:
                            //                                 size.height * 0.03,
                            //                           ),
                            //                           Text(
                            //                             places.data()[
                            //                                         'description'] !=
                            //                                     null
                            //                                 ? places.data()[
                            //                                     'description']
                            //                                 : 'No description',
                            //                             maxLines: 2,
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: GoogleFonts
                            //                                 .montserrat(
                            //                               textStyle: TextStyle(
                            //                                 color:
                            //                                     darkPrimaryColor,
                            //                                 fontSize: 15,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                           SizedBox(
                            //                             height:
                            //                                 size.height * 0.01,
                            //                           ),
                            //                           Text(
                            //                             places.data()['by'] !=
                            //                                     null
                            //                                 ? places
                            //                                     .data()['by']
                            //                                 : 'No company',
                            //                             maxLines: 2,
                            //                             overflow: TextOverflow
                            //                                 .ellipsis,
                            //                             style: GoogleFonts
                            //                                 .montserrat(
                            //                               textStyle: TextStyle(
                            //                                 color:
                            //                                     darkPrimaryColor,
                            //                                 fontSize: 15,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                           SizedBox(
                            //                             height:
                            //                                 size.height * 0.04,
                            //                           ),
                            //                           Row(
                            //                             mainAxisAlignment:
                            //                                 MainAxisAlignment
                            //                                     .center,
                            //                             children: <Widget>[
                            //                               RoundedButton(
                            //                                 width: 0.3,
                            //                                 height: 0.07,
                            //                                 text: 'On Map',
                            //                                 press: () async {
                            //                                   setState(() {
                            //                                     loading = true;
                            //                                   });
                            //                                   Navigator.push(
                            //                                     context,
                            //                                     SlideRightRoute(
                            //                                       page:
                            //                                           HomeScreen(
                            //                                         selected:
                            //                                             'map',
                            //                                         data: [
                            //                                           places.data()[
                            //                                               'lat'],
                            //                                           places.data()[
                            //                                               'lon']
                            //                                         ],
                            //                                       ),
                            //                                     ),
                            //                                   );
                            //                                 },
                            //                                 color:
                            //                                     darkPrimaryColor,
                            //                                 textColor:
                            //                                     whiteColor,
                            //                               ),
                            //                               SizedBox(
                            //                                 width: size.width *
                            //                                     0.04,
                            //                               ),
                            //                               RoundedButton(
                            //                                 width: 0.3,
                            //                                 height: 0.07,
                            //                                 text: 'Order',
                            //                                 press: () async {
                            //                                   setState(() {
                            //                                     loading = true;
                            //                                   });
                            //                                   Navigator.push(
                            //                                     context,
                            //                                     SlideRightRoute(
                            //                                       page:
                            //                                           HomeScreen(
                            //                                         selected:
                            //                                             'favourites',
                            //                                         data: null,
                            //                                       ),
                            //                                     ),
                            //                                   );
                            //                                 },
                            //                                 color:
                            //                                     darkPrimaryColor,
                            //                                 textColor:
                            //                                     whiteColor,
                            //                               ),
                            //                             ],
                            //                           ),
                            //                         ],
                            //                       ),
                            //                     ),
                            //                   ),
                            //                 );
                            //               },
                            //             ),
                            //           );
                            //   },
                            // ),
                          ),
                          SizedBox(
                            height: size.height * 0.105,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
