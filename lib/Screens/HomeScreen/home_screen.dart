import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Screens/PlaceScreen/place_screen.dart';
import 'package:flutter_complete_guide/Services/db/place_db.dart';
import 'package:flutter_complete_guide/widgets/ciw.dart';
import 'package:flutter_complete_guide/widgets/label_button.dart';
import 'package:flutter_complete_guide/widgets/point_object.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Screens/HistoryScreen/history_screen.dart';
import 'package:flutter_complete_guide/Screens/ProfileScreen/profile_screen.dart';
import 'package:flutter_complete_guide/Screens/SearchScreen/search_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    StreamProvider<List<Place>>.value(
      value: PlaceDB().places,
      child: MapPage(
        data: null,
        isLoading: true,
      ),
    ),
    SearchScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarm),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: darkPrimaryColor,
        unselectedItemColor: primaryColor,
        onTap: _onItemTapped,
        backgroundColor: whiteColor,
        elevation: 50,
        iconSize: 33.0,
        selectedFontSize: 17.0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// ignore: must_be_immutable
class MapPage extends StatefulWidget {
  bool isLoading;
  Map data;
  MapPage({this.isLoading, this.data});
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  StreamSubscription _mapIdleSubscription;
  InfoWidgetRoute _infoWidgetRoute;
  bool loading = true;
  Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController _mapController;
  // ignore: avoid_init_to_null
  static LatLng _initialPosition = null;

  @override
  void initState() {
    super.initState();
    loading = widget.isLoading;
    _getPermission();
    _getUserLocation();
  }

  void _getPermission() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void _getUserLocation() async {
    geolocator.Position position = await geolocator.Geolocator()
        .getCurrentPosition(desiredAccuracy: geolocator.LocationAccuracy.high);
    List<geolocator.Placemark> placemark = await geolocator.Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    if (this.mounted) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    }
    print('${placemark[0].name}');
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final places = Provider.of<List<Place>>(context);
    setState(() {
      if (places != null) {
        places.forEach((place) {
          PointObject point = PointObject(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: size.height * 0.04,
                ),
                Text(
                  place.name,
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
                  height: size.height * 0.015,
                ),
                Text(
                  place.by,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      color: darkPrimaryColor,
                      fontSize: 10,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.04,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: RoundedButton(
                          pw: 60,
                          ph: 40,
                          text: 'Book',
                          press: () {
                            setState(() {
                              loading = true;
                            });
                            Navigator.push(
                                context,
                                SlideRightRoute(
                                  page: PlaceScreen(
                                    data: {
                                      'name': place.name, //0
                                      'description': place.description, //1
                                      'by': place.by, //2
                                      'lat': place.lat, //3
                                      'lon': place.lon, //4
                                      'images': place.images, //5
                                      'services': place.services, //6
                                      'id': place.id, //7
                                    },
                                  ),
                                ));
                            setState(() {
                              loading = false;
                            });
                          },
                          color: darkPrimaryColor,
                          textColor: whiteColor,
                        ),
                      ),
                      LabelButton(
                        isC: false,
                        reverse: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser.uid),
                        containsValue: place.id,
                        color1: Colors.red,
                        color2: lightPrimaryColor,
                        ph: 45,
                        pw: 45,
                        size: 40,
                        onTap: () {
                          setState(() {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .update({
                              'favourites': FieldValue.arrayUnion([place.id])
                            });
                          });
                        },
                        onTap2: () {
                          setState(() {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .update({
                              'favourites': FieldValue.arrayRemove([place.id])
                            });
                          });
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
            location: LatLng(place.lat, place.lon),
          );
          _markers.add(Marker(
            markerId: MarkerId(place.name),
            position: LatLng(place.lat, place.lon),
            onTap: () => _onTap(point),
          ));
        });
      }
    });
    return Scaffold(
      body: _initialPosition == null
          ? LoadingScreen()
          : Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                GoogleMap(
                  mapType: MapType.normal,
                  minMaxZoomPreference: MinMaxZoomPreference(10.0, 40.0),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: widget.data != null
                        ? LatLng(widget.data['lat'], widget.data['lon'])
                        : _initialPosition,
                    zoom: 15,
                  ),
                  markers: _markers,
                  onCameraMove: (newPosition) {
                    _mapIdleSubscription?.cancel();
                    _mapIdleSubscription =
                        Future.delayed(Duration(milliseconds: 150))
                            .asStream()
                            .listen((_) {
                      if (_infoWidgetRoute != null) {
                        Navigator.of(context, rootNavigator: true)
                            .push(_infoWidgetRoute)
                            .then<void>(
                          (newValue) {
                            _infoWidgetRoute = null;
                          },
                        );
                      }
                    });
                  },
                ),
                (loading)
                    ? Positioned.fill(
                        child: Center(
                          child: LoadingScreen(),
                          // child: Scaffold(
                          //   body: AnimatedContainer(
                          //     curve: Curves.fastOutSlowIn,
                          //     duration: const Duration(milliseconds: 100),
                          //     color: whiteColor,
                          //     child: Center(
                          //       child: Image.asset(
                          //         'assets/images/Loading.png',
                          //         width: 1 * size.width,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ),
                      )
                    : Container()
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _onTap(PointObject point) async {
    final RenderBox renderBox = context.findRenderObject();
    Rect _itemRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;

    _infoWidgetRoute = InfoWidgetRoute(
      child: point.child,
      buildContext: context,
      textStyle: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      mapsWidgetSize: _itemRect,
    );

    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            point.location.latitude - 0.0001,
            point.location.longitude,
          ),
          zoom: 15,
        ),
      ),
    );
    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            point.location.latitude,
            point.location.longitude,
          ),
          zoom: 15,
        ),
      ),
    );
  }
}

// class FlutterPage extends StatelessWidget {
//   final Color backgroundColor;
//   final String title;

//   const FlutterPage({Key key, this.backgroundColor, this.title})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       alignment: Alignment.center,
//       color: backgroundColor,
//       padding: EdgeInsets.symmetric(
//           horizontal: MediaQuery.of(context).size.width * 0.1, vertical: 120.0),
//       child: Column(
//         children: <Widget>[
//           Text(title,
//               style: TextStyle(
//                 color: const Color(0xBB000000),
//                 fontSize: 35.0,
//                 fontWeight: FontWeight.w700,
//               )),
//               RoundedButton(
//                 width: 0.7,
//                 height: 0.085,
//                 text: 'SIGN OUT',
//                 press: () {
//                   // setState(() {
//                   //   loading = true;
//                   // });
//                   dynamic res = AuthService().signOut();
//                   // if(res == null){
//                   //   loading = false;
//                   // }
//                 },
//                 color: darkPrimaryColor,
//                 textColor: whiteColor,
//               )
//         ],
//       ),
//     );
//   }
// }

class PageReveal extends StatelessWidget {
  final double revealPercent;
  final Widget child;

  const PageReveal({Key key, this.revealPercent, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      clipper: CircleRevealClipper(revealPercent),
      child: child,
    );
  }
}

class CircleRevealClipper extends CustomClipper<Rect> {
  final double revealPercent;

  CircleRevealClipper(this.revealPercent);

  @override
  Rect getClip(Size size) {
    final epicenter = Offset(size.width / 2, size.height * 0.5);
    double theta = atan(epicenter.dy / epicenter.dx);
    final distanceToCorner = epicenter.dy / sin(theta);

    final radius = distanceToCorner * revealPercent;

    final diameter = 2 * radius;

    return Rect.fromLTWH(
        epicenter.dx - radius, epicenter.dy - radius, diameter, diameter);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

// class _HomeScreenState extends State<HomeScreen> {
//   String phoneNo;
//   String smsCode;
//   String verificationId;
//   bool loading = false;

//   @override
//   Widget build(BuildContext context) {

//     Size size = MediaQuery.of(context).size;
//     return loading ? LoadingScreen() : Scaffold(
//       backgroundColor: whiteColor,
//       body: SingleChildScrollView(
//         child: Background(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text(
//                 'WELCOME TO FOOTY',
//                 style: GoogleFonts.montserrat(
//                   textStyle: TextStyle(
//                     color: whiteColor,
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: size.height * 0.03,
//               ),
//               Text(
//                 'HOME',
//                 style: GoogleFonts.montserrat(
//                   textStyle: TextStyle(
//                     color: whiteColor,
//                     fontSize: 25,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               SizedBox(height: size.height * 0.2),
//               RoundedButton(
//                 text: 'SIGN OUT',
//                 press: () {
//                   setState(() {
//                     loading = true;
//                   });
//                   dynamic res = AuthService().signOut();
//                   if(res == null){
//                     loading = false;
//                   }
//                 },
//                 color: darkPrimaryColor,
//                 textColor: whiteColor,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
