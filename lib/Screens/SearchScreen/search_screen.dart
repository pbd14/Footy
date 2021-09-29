import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Screens/HomeScreen/home_screen.dart';
import 'package:flutter_complete_guide/Screens/PlaceScreen/place_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/Services/languages/languages.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/rounded_text_input.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  List _results = [];
  Future resultsLoaded;
  bool loading = false;
  bool loading1 = false;
  QuerySnapshot all;

  Future<void> search(String st) async {
    setState(() {
      loading1 = true;
    });
    setState(() {
      List preresults = [];
      for (var doc in all.docs) {
        if (doc.data()['name'] != null) {
          if (doc.data()['name'].toLowerCase().contains(st.toLowerCase())) {
            preresults.add(doc);
          }
        }
      }
      _results = preresults;
      loading1 = false;
      preresults = [];
    });
  }

  Future<void> prepare() async {
    all = await FirebaseFirestore.instance.collection('locations').get();
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('locations')
        .orderBy('name')
        .limit(20)
        .get();
    if (this.mounted) {
      setState(() {
        _results = qs.docs;
        loading = false;
      });
    } else {
      _results = qs.docs;
      loading = false;
    }
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: darkPrimaryColor,
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RoundedTextInput(
                        height: 70,
                        icon: Icons.search,
                        hintText: Languages.of(context).searchScreenName,
                        type: TextInputType.text,
                        onChanged: (value) {
                          value != null
                              ? value.length != 0
                                  ? search(value)
                                  : prepare()
                              : prepare();
                        },
                      ),
                      Expanded(
                        child: loading1
                            ? LoadingScreen()
                            : ListView.builder(
                                itemCount: _results.length,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 10.0),
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
                                              width: size.width * 0.5,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    Place.fromSnapshot(
                                                            _results[index])
                                                        .name,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: darkColor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
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
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                          color: darkColor,
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
                                                width: size.width * 0.3,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        CupertinoIcons
                                                            .map_pin_ellipse,
                                                        color: darkPrimaryColor,
                                                      ),
                                                      onPressed: () async {
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
                                                    ),
                                                    SizedBox(width: 10),
                                                    IconButton(
                                                      icon: Icon(
                                                        CupertinoIcons.book,
                                                        color: darkPrimaryColor,
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        Navigator.push(
                                                          context,
                                                          SlideRightRoute(
                                                            page: PlaceScreen(
                                                              placeId: _results[
                                                                      index]
                                                                  .id,
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
