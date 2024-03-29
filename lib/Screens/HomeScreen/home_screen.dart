import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Models/PushNotificationMessage.dart';
import 'package:flutter_complete_guide/Screens/PlaceScreen/place_screen.dart';
import 'package:flutter_complete_guide/Services/languages/languages.dart';
import 'package:flutter_complete_guide/widgets/ciw.dart';
import 'package:flutter_complete_guide/widgets/label_button.dart';
import 'package:flutter_complete_guide/widgets/point_object.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_fonts/google_fonts.dart';
import 'package:native_updater/native_updater.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Screens/HistoryScreen/history_screen.dart';
import 'package:flutter_complete_guide/Screens/ProfileScreen/profile_screen.dart';
import 'package:flutter_complete_guide/Screens/SearchScreen/search_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, double> data = null;

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool isNotif = false;
  bool isProfileNotif = false;
  int _selectedIndex = 0;
  int notifCounter = 0;
  int profileNotifCounter = 0;
  StreamSubscription<QuerySnapshot> subscription;
  StreamSubscription<DocumentSnapshot> userSubscription;
  static List<Widget> _widgetOptions = <Widget>[
    MapPage(
      data: data,
      isLoading: true,
      isAppBar: false,
    ),
    SearchScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  // void goTo(double lat, double lon) {
  //   print("YESS");
  //   if (this.mounted) {
  //     print('HERE');
  //     setState(() {
  //       _widgetOptions = <Widget>[
  //         MapPage(
  //           data: data,
  //           isLoading: true,
  //         ),
  //         SearchScreen(),
  //         HistoryScreen(),
  //         ProfileScreen(),
  //       ];
  //       data = {'lat': lat, 'lon': lon};
  //       _selectedIndex = 0;
  //     });
  //   } else {
  //     print('NO STATE');
  //     _widgetOptions = <Widget>[
  //       MapPage(
  //         data: data,
  //         isLoading: true,
  //       ),
  //       SearchScreen(),
  //       HistoryScreen(),
  //       ProfileScreen(),
  //     ];
  //     data = {'lat': lat, 'lon': lon};
  //     _selectedIndex = 0;
  //   }
  // }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> prepare() async {
    final prefs = await SharedPreferences.getInstance();
    final value1 = prefs.getBool('local_auth') ?? false;
    if (value1) {
      // Navigator.push(
      //   context,
      //   SlideRightRoute(
      //     page: ScreenLock(
      //       correctString: prefs.getString('local_password'),
      //       canCancel: false,
      //     ),
      //   ),
      // );
      screenLock(
          context: context,
          correctString: prefs.getString('local_password'),
          canCancel: false);
    }
  }

  Future<void> checkUserProfile() async {
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    if (!user.exists) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .set({
        'status': 'default',
        'cancellations_num': 0,
        'phone': FirebaseAuth.instance.currentUser.phoneNumber,
      });
    }
  }

  Future<void> checkVersion() async {
    RemoteConfig remoteConfig = RemoteConfig.instance;
    // ignore: unused_local_variable
    bool updated = await remoteConfig.fetchAndActivate();
    String requiredVersion = remoteConfig.getString(Platform.isAndroid
        ? 'footy_google_play_version'
        : 'footy_appstore_version');
    String appStoreLink = remoteConfig.getString('footy_appstore_link');
    String googlePlayLink = remoteConfig.getString('footy_google_play_link');

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (packageInfo.version != requiredVersion) {
      print('DONE');
      NativeUpdater.displayUpdateAlert(
        context,
        forceUpdate: true,
        appStoreUrl: appStoreLink,
        playStoreUrl: googlePlayLink,
      );
    }
  }

  @override
  void initState() {
    checkUserProfile();
    checkVersion();
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

    userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((docsnap) {
      if (docsnap.data() != null) {
        if (docsnap.data()['notifications'] != null) {
          if (docsnap.data()['notifications'].length != 0) {
            List acts = [];
            for (var act in docsnap.data()['notifications']) {
              if (!act['seen']) {
                acts.add(act);
              }
            }
            if (acts.length != 0) {
              setState(() {
                isProfileNotif = true;
                profileNotifCounter = acts.length;
              });
            } else {
              if (this.mounted) {
                setState(() {
                  isProfileNotif = false;
                  profileNotifCounter = 0;
                });
              } else {
                isProfileNotif = false;
                profileNotifCounter = 0;
              }
            }
          } else {
            setState(() {
              isProfileNotif = false;
              profileNotifCounter = 0;
            });
          }
        } else {
          setState(() {
            isProfileNotif = false;
            profileNotifCounter = 0;
          });
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map_pin_ellipse),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: isNotif
                ? new Stack(
                    children: <Widget>[
                      new Icon(CupertinoIcons.clock),
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
            label: '',
          ),
          BottomNavigationBarItem(
            icon: isProfileNotif
                ? new Stack(
                    children: <Widget>[
                      new Icon(CupertinoIcons.person_fill),
                      new Positioned(
                        right: 0,
                        child: new Container(
                          padding: EdgeInsets.all(1),
                          decoration: new BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 15,
                            minHeight: 15,
                          ),
                          child: new Text(
                            profileNotifCounter.toString(),
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  )
                : Icon(CupertinoIcons.person_fill),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: whiteColor,
        onTap: _onItemTapped,
        backgroundColor: darkColor,
        elevation: 50,
        iconSize: 33.0,
        selectedIconTheme: IconThemeData(
          size: 40,
        ),
        selectedFontSize: 0.0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// ignore: must_be_immutable
class MapPage extends StatefulWidget {
  bool isLoading;
  bool isAppBar = false;
  Map data;
  MapPage({this.isLoading, this.data, this.isAppBar});
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
    QuerySnapshot data =
        await FirebaseFirestore.instance.collection('locations').get();
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
            case 'health':
              {
                categoryLine = 'assets/icons/health.png';
                cardColor = Colors.red[800];
                categoryIcon = Icon(
                  Icons.medical_services,
                  size: 24,
                  color: whiteColor,
                );
              }
              break;
            case 'beauty':
              {
                categoryLine = 'assets/icons/beauty.png';
                cardColor = Colors.purple[800];
                categoryIcon = Icon(
                  CupertinoIcons.scissors,
                  size: 24,
                  color: whiteColor,
                );
              }
              break;

            case 'food':
              {
                categoryLine = 'assets/icons/food.png';
                cardColor = Colors.orange[400];
                categoryIcon = Icon(
                  Icons.food_bank_rounded,
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
                              rating.toStringAsFixed(1),
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
                            ph: 50,
                            text: Languages.of(context).homeScreenBook,
                            press: () {
                              setState(() {
                                loading = true;
                              });
                              Navigator.push(
                                  context,
                                  SlideRightRoute(
                                    page: PlaceScreen(
                                      placeId: place.id,
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
                                  title: Languages.of(context).homeScreenFail,
                                  body: Languages.of(context)
                                      .homeScreenFailedToUpdate,
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
                                  Languages.of(context).homeScreenSaved,
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
                                  title: Languages.of(context).homeScreenFail,
                                  body: Languages.of(context)
                                      .homeScreenFailedToUpdate,
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
                                  Languages.of(context).homeScreenSaved,
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
              ImageConfiguration(devicePixelRatio: 3), categoryLine,);
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
      appBar: widget.isAppBar
          ? AppBar(
              backgroundColor: darkColor,
              iconTheme: IconThemeData(color: primaryColor),
            )
          : null,
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
