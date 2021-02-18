import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Booking.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Screens/MapScreen/map_screen.dart';
import 'package:flutter_complete_guide/widgets/card.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class OnEventScreen extends StatefulWidget {
  final dynamic booking;
  OnEventScreen({Key key, this.booking}) : super(key: key);
  @override
  _OnEventScreenState createState() => _OnEventScreenState();
}

class _OnEventScreenState extends State<OnEventScreen> {
  // GoogleMapController _mapController;
  bool loading = false;
  double initRat = 3;
  var place;

  Future<void> prepare() async {
    place = await FirebaseFirestore.instance
        .collection('locations')
        .doc(Booking.fromSnapshot(widget.booking).placeId)
        .get();
    setState(() {
      if (Place.fromSnapshot(place).rates != null) {
        if (Place.fromSnapshot(place)
            .rates
            .containsKey(Booking.fromSnapshot(widget.booking).id)) {
          initRat = Place.fromSnapshot(place)
              .rates[Booking.fromSnapshot(widget.booking).id];
        }
      }
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    prepare();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
            ),
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                    expandedHeight: size.height * 0.4,
                    backgroundColor: darkPrimaryColor,
                    floating: false,
                    pinned: false,
                    snap: false,
                    flexibleSpace: Center(
                      child: Text(
                        Place.fromSnapshot(place) != null
                            ? Place.fromSnapshot(place).name
                            : 'Place',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: whiteColor,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    )),
                SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(
                      height: size.height * 0.04,
                    ),
                    // Container(
                    //   height: 400,
                    //   child: GoogleMap(
                    //     mapType: MapType.normal,
                    //     minMaxZoomPreference: MinMaxZoomPreference(10.0, 40.0),
                    //     myLocationEnabled: true,
                    //     myLocationButtonEnabled: true,
                    //     mapToolbarEnabled: false,
                    //     onMapCreated: _onMapCreated,
                    //     initialCameraPosition: CameraPosition(
                    //       target: LatLng(Place.fromSnapshot(place).lat,
                    //           Place.fromSnapshot(place).lon),
                    //       zoom: 15,
                    //     ),
                    //     markers: Set.from([
                    //       Marker(
                    //           markerId: MarkerId('1'),
                    //           draggable: false,
                    //           position: LatLng(Place.fromSnapshot(place).lat,
                    //               Place.fromSnapshot(place).lon))
                    //     ]),
                    //   )

                    Center(
                      child: CardW(
                        ph: 140,
                        bgColor: darkPrimaryColor,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: size.width * 0.8,
                            ),
                            Text(
                              DateFormat.yMMMd()
                                  .format(Booking.fromSnapshot(widget.booking)
                                      .timestamp_date
                                      .toDate())
                                  .toString(),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: whiteColor,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              Booking.fromSnapshot(widget.booking).from +
                                  ' - ' +
                                  Booking.fromSnapshot(widget.booking).to,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: whiteColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              Booking.fromSnapshot(widget.booking)
                                      .price
                                      .toString() +
                                  " So'm",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
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
                    SizedBox(
                      height: 5,
                    ),
                    Center(
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            loading = true;
                          });
                          Navigator.push(
                            context,
                            SlideRightRoute(
                              page: MapScreen(
                                data: {
                                  'lat': Place.fromSnapshot(place).lat,
                                  'lon': Place.fromSnapshot(place).lon
                                },
                              ),
                            ),
                          );
                          setState(() {
                            loading = false;
                          });
                        },
                        child: CardW(
                          ph: 70,
                          bgColor: darkPrimaryColor,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: size.width * 0.6,
                              ),
                              Text(
                                'On Map',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: whiteColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: RatingBar.builder(
                        initialRating: initRat,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: darkPrimaryColor,
                        ),
                        onRatingUpdate: (rating) {
                          var dataBooking =
                              Booking.fromSnapshot(widget.booking).id;
                          FirebaseFirestore.instance
                              .collection('locations')
                              .doc(Place.fromSnapshot(place).id)
                              .update({'rates.$dataBooking': rating});
                        },
                      ),
                    )
                  ]),
                ),
              ],

              // SliverAppBar(
              //   expandedHeight: size.height * 0.4,
              //   backgroundColor: darkPrimaryColor,
              //   flexibleSpace: Text(
              //     'App bar',
              // overflow: TextOverflow.ellipsis,
              // style: GoogleFonts.montserrat(
              //   textStyle: TextStyle(
              //     color: darkPrimaryColor,
              //     fontSize: 25,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // ),
              // flexibleSpace: GoogleMap(
              //   mapType: MapType.normal,
              //   minMaxZoomPreference: MinMaxZoomPreference(10.0, 40.0),
              //   myLocationEnabled: true,
              //   myLocationButtonEnabled: true,
              //   mapToolbarEnabled: false,
              //   onMapCreated: _onMapCreated,
              //   initialCameraPosition: CameraPosition(
              //     target: LatLng(Place.fromSnapshot(place).lat,
              //         Place.fromSnapshot(place).lon),
              //     zoom: 15,
              //   ),
              //   markers: _markers,
              // ),
              // ),
              // SliverList(
              //   delegate: SliverChildListDelegate([
              //     Text(
              //       'No events',
              //       overflow: TextOverflow.ellipsis,
              //       style: GoogleFonts.montserrat(
              //         textStyle: TextStyle(
              //           color: darkPrimaryColor,
              //           fontSize: 25,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ]),
              // ),
              // ],
            ),
          );
  }
}
