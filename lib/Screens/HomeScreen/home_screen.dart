import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Screens/PlaceScreen/place_screen.dart';
import 'package:flutter_complete_guide/Services/db/place_db.dart';
import 'package:flutter_complete_guide/widgets/ciw.dart';
import 'package:flutter_complete_guide/widgets/point_object.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bottom_personalized_dot_bar/bottom_personalized_dot_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Screens/FavouritesScreen/favourites_screen.dart';
import 'package:flutter_complete_guide/Screens/HistoryScreen/history_screen.dart';
import 'package:flutter_complete_guide/Screens/ProfileScreen/profile_screen.dart';
import 'package:flutter_complete_guide/Screens/SearchScreen/search_screen.dart';
import 'package:flutter_complete_guide/Screens/SettingsScreen/settings_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

bool loading = false;

class HomeScreen extends StatefulWidget {
  String selected;
  Map data;
  HomeScreen({Key key, this.selected, this.data}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _itemSelected = 'map';
  bool _enableAnimation = true;

  @override
  void initState() {
    super.initState();
    if (widget.selected != null) {
      setState(() {
        _itemSelected = widget.selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              switchOutCurve: Interval(0.0, 0.0),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final revealAnimation = Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.ease));
                return AnimatedBuilder(
                  builder: (BuildContext context, Widget _) {
                    return _buildAnimation(
                        context, _itemSelected, child, revealAnimation.value);
                  },
                  animation: animation,
                );
              },
              child: _buildPage(_itemSelected),
            ),
            BottomPersonalizedDotBar(
              dotColor: darkPrimaryColor,
              selectedColorIcon: darkPrimaryColor,
              unSelectedColorIcon: primaryColor,
              height: size.height * 0.12,
              width: (MediaQuery.of(context).size.width > 600) ? 500.0 : null,
              keyItemSelected: _itemSelected,
              doneText: 'Done',
              settingTitleText: 'Your Menu',
              settingSubTitleText: 'Drag and drop',
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10.0, spreadRadius: 1.0)
              ],
              iconSettingColor: primaryColor,
              buttonDoneColor: primaryColor,
              settingSubTitleColor: primaryColor,
              hiddenItems: <BottomPersonalizedDotBarItem>[
                BottomPersonalizedDotBarItem('favourites',
                    icon: Icons.favorite_border,
                    name: 'Favourites',
                    onTap: (itemSelected) => _changePage(itemSelected)),
                BottomPersonalizedDotBarItem('settings',
                    icon: Icons.settings,
                    name: 'Settings',
                    onTap: (itemSelected) => _changePage(itemSelected)),
              ],
              items: <BottomPersonalizedDotBarItem>[
                BottomPersonalizedDotBarItem('map',
                    icon: Icons.map,
                    name: 'Map',
                    onTap: (itemSelected) => _changePage(itemSelected)),
                BottomPersonalizedDotBarItem('search',
                    icon: Icons.search,
                    name: 'Search',
                    onTap: (itemSelected) => _changePage(itemSelected)),
                BottomPersonalizedDotBarItem('history',
                    icon: Icons.access_alarm,
                    name: 'History',
                    onTap: (itemSelected) => _changePage(itemSelected)),
                BottomPersonalizedDotBarItem('profile',
                    icon: Icons.face,
                    name: 'Profile',
                    onTap: (itemSelected) => _changePage(itemSelected)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _changePage(String itemSelected) {
    if (_itemSelected != itemSelected && _enableAnimation) {
      _enableAnimation = false;
      setState(() {
        _itemSelected = itemSelected;
        widget.data = null;
      });
      Future.delayed(
          const Duration(milliseconds: 700), () => _enableAnimation = true);
    }
  }

  Widget _buildAnimation(BuildContext context, String itemSelected,
      Widget child, double valueAnimation) {
    switch (itemSelected) {
      case 'map':
        return Transform.translate(
            offset: Offset(
                .0,
                -(valueAnimation - 1).abs() *
                    MediaQuery.of(context).size.width),
            child: child);
      // case 'item-2':
      //   return PageReveal(revealPercent: valueAnimation, child: child);
      // case 'item-3':
      //   return Opacity(opacity: valueAnimation, child: child);
      // case 'item-4':
      //   return Transform.translate(
      //       offset: Offset(
      //           -(valueAnimation - 1).abs() * MediaQuery.of(context).size.width,
      //           .0),
      //       child: child);
      // case 'item-5':
      //   return Transform.translate(
      //       offset: Offset(
      //           (valueAnimation - 1).abs() * MediaQuery.of(context).size.width,
      //           .0),
      //       child: child);
      // case 'item-6':
      //   return Transform.translate(
      //       offset: Offset(.0,
      //           (valueAnimation - 1).abs() * MediaQuery.of(context).size.width),
      //       child: child);
      default:
        return PageReveal(revealPercent: valueAnimation, child: child);
    }
  }

  Widget _buildPage(String itemSelected) {
    switch (itemSelected) {
      case 'map':
        Map permanentData = widget.data;
        widget.data = null;
        return StreamProvider<List<Place>>.value(
          value: PlaceDB().places,
          child: MapPage(
            data: permanentData != null ? permanentData : null,
            isLoading: true,
          ),
        );
      case 'search':
        return SearchScreen();
      case 'favourites':
        return FavouritesScreen();
      case 'profile':
        return ProfileScreen();
      case 'history':
        return HistoryScreen();
      case 'settings':
        return SettingsScreen();
      case 'place':
        return PlaceScreen(
          data: widget.data,
        );
    }
  }
}

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
                RoundedButton(
                  width: 0.6,
                  height: 0.07,
                  text: 'Book',
                  press: () async {
                    setState(() {
                      loading = true;
                    });
                    Navigator.push(
                        context,
                        SlideRightRoute(
                          page: HomeScreen(
                            selected: 'place',
                            data: {
                              'name' : place.name, //0
                              'description' : place.description, //1
                              'by' : place.by, //2
                              'lat' : place.lat, //3
                              'lon' : place.lon, //4
                              'images' : place.images, //5
                              'days' : place.days,
                              'spm' : place.spm, //6
                              'type' : place.type,
                              'id' : place.id, //7
                            },
                          ),
                        ));
                  },
                  color: darkPrimaryColor,
                  textColor: whiteColor,
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
