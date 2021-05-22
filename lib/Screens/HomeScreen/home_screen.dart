import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Models/PushNotificationMessage.dart';
import 'package:flutter_complete_guide/Screens/PlaceScreen/place_screen.dart';
import 'package:flutter_complete_guide/Services/db/place_db.dart';
import 'package:flutter_complete_guide/widgets/ciw.dart';
import 'package:flutter_complete_guide/widgets/label_button.dart';
import 'package:flutter_complete_guide/widgets/point_object.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
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
  bool isNotif = false;
  int _selectedIndex = 0;
  int notifCounter = 0;
  // ignore: cancel_subscriptions
  StreamSubscription<QuerySnapshot> subscription;
  static List<Widget> _widgetOptions = <Widget>[
    StreamProvider<List<Place>>.value(
      initialData: [],
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
  void initState() {
    subscription = FirebaseFirestore.instance
        .collection('bookings')
        .where(
          'status',
          isEqualTo: 'in process',
        )
        .where(
          'userId',
          isEqualTo: FirebaseAuth.instance.currentUser.uid.toString(),
        )
        .where('seen_status', whereIn: ['unseen'])
        .snapshots()
        .listen((docsnap) {
          if (docsnap != null) {
            if (docsnap.docs.length != 0) {
              setState(() {
                isNotif = true;
                notifCounter = docsnap.docs.length;
              });
            } else {
              setState(() {
                isNotif = false;
                notifCounter = 0;
              });
            }
          } else {
            setState(() {
              isNotif = false;
              notifCounter = 0;
            });
          }
          // if (docsnap.data()['favourites'].contains(widget.containsValue)) {
          //   setState(() {
          //     isColored = true;
          //     isOne = false;
          //   });
          // } else if (!docsnap.data()['favourites'].contains(widget.containsValue)) {
          //   setState(() {
          //     isColored = false;
          //     isOne = true;
          //   });
          // }
        });
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      // Center(
      //   child: _widgetOptions.elementAt(_selectedIndex),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map_pin_ellipse),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: isNotif
                ? new Stack(
                    children: <Widget>[
                      new Icon(Icons.access_alarm),
                      new Positioned(
                        right: 0,
                        child: new Container(
                          padding: EdgeInsets.all(1),
                          decoration: new BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 15,
                            minHeight: 15,
                          ),
                          child: new Text(
                            notifCounter.toString(),
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  )
                : Icon(CupertinoIcons.clock),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_alt),
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
  double ratingSum = 0;
  double rating = 0;
  Widget categoryIcon;
  Color cardColor;
  BitmapDescriptor pinLocationIcon;
  String categoryLine = 'assets/icons/default.png';

  @override
  void initState() {
    super.initState();
    loading = widget.isLoading;
    _getPermission();
    _getUserLocation();
    prepare();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
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
    geolocator.Position position =
        await geolocator.Geolocator.getCurrentPosition(
            desiredAccuracy: geolocator.LocationAccuracy.high);
    if (this.mounted) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    }
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

  void prepare() async {
    // final places = Provider.of<List<Place>>(context);
    var data = await FirebaseFirestore.instance.collection('locations').get();
    final places = data.docs;

    setState(() {
      if (places != null) {
        places.forEach((place) async {
          if (Place.fromSnapshot(place).rates != null) {
            if (Place.fromSnapshot(place).rates.length != 0) {
              for (var rate in Place.fromSnapshot(place).rates.values) {
                ratingSum += rate;
              }
              rating = ratingSum / Place.fromSnapshot(place).rates.length;
            }
          }

          // FirebaseFirestore.instance
          //     .collection('locations')
          //     .doc('BZorwr8lMphWTavotdsy')
          //     .get()
          //     .then((value) {
          //   print(value.data()['name']);
          //   print(value.data()['rates']);
          // });

          switch (Place.fromSnapshot(place).category) {
            case 'sport':
              {
                categoryLine = 'assets/icons/sport.png';
                cardColor = darkPrimaryColor;
                categoryIcon = Icon(
                  Icons.sports_soccer,
                  size: 24,
                  color: whiteColor,
                );
              }
              break;

            case 'entertainment':
              {
                categoryLine = 'assets/icons/entertainment.png';
                cardColor = Colors.yellow[800];
                categoryIcon = Icon(
                  Icons.auto_awesome,
                  size: 24,
                  color: whiteColor,
                );
              }
              break;

            default:
              {
                categoryLine = 'assets/icons/default.png';
                cardColor = Colors.blueGrey[900];
                categoryIcon = Icon(
                  CupertinoIcons.globe,
                  size: 24,
                  color: whiteColor,
                );
              }
              break;
          }

          PointObject point = PointObject(
            child: Container(
              color: cardColor,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    Place.fromSnapshot(place).name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        color: whiteColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Place.fromSnapshot(place).by != null
                            ? Place.fromSnapshot(place).by
                            : 'By',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: whiteColor,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      categoryIcon,
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: whiteColor,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              rating.toStringAsFixed(1) + '/5',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: whiteColor,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
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
                                        'name':
                                            Place.fromSnapshot(place).name, //0
                                        'description': Place.fromSnapshot(place)
                                            .description, //1
                                        'by': Place.fromSnapshot(place).by, //2
                                        'lat':
                                            Place.fromSnapshot(place).lat, //3
                                        'lon':
                                            Place.fromSnapshot(place).lon, //4
                                        'images': Place.fromSnapshot(place)
                                            .images, //5
                                        'services':
                                            Place.fromSnapshot(place).services,
                                        'rates':
                                            Place.fromSnapshot(place).rates,
                                        'category': Place.fromSnapshot(place)
                                            .category, //6
                                        'id': Place.fromSnapshot(place).id, //7
                                      },
                                    ),
                                  ));
                              setState(() {
                                loading = false;
                              });
                            },
                            color: whiteColor,
                            textColor: darkPrimaryColor,
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
                              }).catchError((error) {
                                PushNotificationMessage notification =
                                    PushNotificationMessage(
                                  title: 'Fail',
                                  body: 'Failed to update favourites',
                                );
                                showSimpleNotification(
                                  Container(child: Text(notification.body)),
                                  position: NotificationPosition.top,
                                  background: Colors.red,
                                );
                              });
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 2),
                                backgroundColor: darkPrimaryColor,
                                content: Text(
                                  'Saved to favourites',
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: whiteColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          onTap2: () {
                            setState(() {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .update({
                                'favourites': FieldValue.arrayRemove([place.id])
                              }).catchError((error) {
                                PushNotificationMessage notification =
                                    PushNotificationMessage(
                                  title: 'Fail',
                                  body: 'Failed to update favourites',
                                );
                                showSimpleNotification(
                                  Container(child: Text(notification.body)),
                                  position: NotificationPosition.top,
                                  background: Colors.red,
                                );
                              });
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Removed from favourites',
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: whiteColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            location: LatLng(
                Place.fromSnapshot(place).lat, Place.fromSnapshot(place).lon),
          );
          pinLocationIcon = await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(devicePixelRatio: 2.5), categoryLine);
          _markers.add(Marker(
            markerId: MarkerId(Place.fromSnapshot(place).name),
            position: LatLng(
                Place.fromSnapshot(place).lat, Place.fromSnapshot(place).lon),
            onTap: () => _onTap(point),
            icon: pinLocationIcon,
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
