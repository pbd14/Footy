import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Booking.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:intl/intl.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OnEventScreen extends StatefulWidget {
  final dynamic booking;
  OnEventScreen({Key key, this.booking}) : super(key: key);
  @override
  _OnEventScreenState createState() => _OnEventScreenState();
}

class _OnEventScreenState extends State<OnEventScreen> {
  GoogleMapController _mapController;
  bool loading = false;
  var place;

  Future<void> prepare() async {
    place = await FirebaseFirestore.instance
        .collection('locations')
        .doc(Booking.fromSnapshot(widget.booking).placeId)
        .get();
    setState(() {
      loading = false;
    });
  }

  void _setMapStyle() async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/images/map_style.json');
    _mapController.setMapStyle(style);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      loading = false;
    });
    _setMapStyle();
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
                  flexibleSpace: GoogleMap(
                    mapType: MapType.normal,
                    minMaxZoomPreference: MinMaxZoomPreference(10.0, 40.0),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    mapToolbarEnabled: false,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(Place.fromSnapshot(place).lat,
                          Place.fromSnapshot(place).lon),
                      zoom: 15,
                    ),
                    markers: Set.from([
                      Marker(
                          markerId: MarkerId('1'),
                          draggable: false,
                          position: LatLng(Place.fromSnapshot(place).lat,
                              Place.fromSnapshot(place).lon))
                    ]),
                  ),
                ),
                // SliverList(
                //   delegate: SliverChildListDelegate([

                //   ]),
                // ),
                SliverFillRemaining(
                  child: Container(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 15, 0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: size.height * 0.04,
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
                                  color: darkPrimaryColor,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              Booking.fromSnapshot(widget.booking).from +
                                  ' - ' +
                                  Booking.fromSnapshot(widget.booking).to,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: darkPrimaryColor,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Text(
                              Place.fromSnapshot(place).name != null
                                  ? Place.fromSnapshot(place).name
                                  : 'Place',
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
                                Booking.fromSnapshot(widget.booking).info !=
                                        null
                                    ? Booking.fromSnapshot(widget.booking).info
                                    : 'No info',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: darkPrimaryColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            SizedBox(
                              height: size.height * 0.05,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
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
