import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';
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
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
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
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
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
                : Icon(Icons.access_alarm),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
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

  ClusterManager _manager;
  List<ClusterItem<Place>> items = [];

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

  void _updateMarkers(Set<Marker> markers) {
    print('Updated ${markers.length} markers');
    setState(() {
      this._markers = markers;
    });
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
    _manager.setMapController(controller);
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

          items.add(ClusterItem(LatLng(
              Place.fromSnapshot(place).lat, Place.fromSnapshot(place).lon)));

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
        _manager = ClusterManager<Place>(items, _updateMarkers,
            markerBuilder: _markerBuilder, initialZoom: 10);
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
                    _manager.onCameraMove(newPosition);
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
                  onCameraIdle: _manager.updateMap,
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

  Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
      (cluster) async {
        print('CLUSTERS HERE');
        print(cluster.items);
        String mcategoryLine;
        Color mcardColor;
        Widget mcategoryIcon;
        Place place = cluster.items.first;
        switch (place != null ? place.category : 'def') {
          case 'sport':
            {
              mcategoryLine = 'assets/icons/sport.png';
              mcardColor = darkPrimaryColor;
              mcategoryIcon = Icon(
                Icons.sports_soccer,
                size: 24,
                color: whiteColor,
              );
            }
            break;

          case 'entertainment':
            {
              mcategoryLine = 'assets/icons/entertainment.png';
              mcardColor = Colors.yellow[800];
              mcategoryIcon = Icon(
                Icons.auto_awesome,
                size: 24,
                color: whiteColor,
              );
            }
            break;
          case 'def':
            {
              mcategoryLine = 'assets/icons/default.png';
              mcardColor = Colors.blueGrey[900];
              mcategoryIcon = Icon(
                CupertinoIcons.globe,
                size: 24,
                color: whiteColor,
              );
            }
            break;

          default:
            {
              mcategoryLine = 'assets/icons/default.png';
              mcardColor = Colors.blueGrey[900];
              mcategoryIcon = Icon(
                CupertinoIcons.globe,
                size: 24,
                color: whiteColor,
              );
            }
            break;
        }
        BitmapDescriptor thisPinLocationIcon =
            await BitmapDescriptor.fromAssetImage(
                ImageConfiguration(devicePixelRatio: 2.5), mcategoryLine);
        return cluster.isMultiple
            ? Marker(
                markerId: MarkerId(cluster.getId()),
                position: cluster.location,
                onTap: () {
                  print('---- $cluster');
                  cluster.items.forEach((p) => print(p));
                },
                icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
                    text: cluster.isMultiple ? cluster.count.toString() : null),
              )
            : place != null
                ? Marker(
                    markerId: MarkerId(place.name),
                    position: LatLng(place.lat, place.lon),
                    onTap: () => _onTap(
                      PointObject(
                        child: Container(
                          color: mcardColor,
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 40,
                              ),
                              Text(
                                place.name,
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
                                    place.by != null ? place.by : 'By',
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
                                  mcategoryIcon,
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                                    'name': place.name, //0
                                                    'description':
                                                        place.description, //1
                                                    'by': place.by, //2
                                                    'lat': place.lat, //3
                                                    'lon': place.lon, //4
                                                    'images': place.images, //5
                                                    'services': place.services,
                                                    'rates': place.rates,
                                                    'category':
                                                        place.category, //6
                                                    'id': place.id, //7
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
                                          .doc(FirebaseAuth
                                              .instance.currentUser.uid),
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
                                              .doc(FirebaseAuth
                                                  .instance.currentUser.uid)
                                              .update({
                                            'favourites': FieldValue.arrayUnion(
                                                [place.id])
                                          }).catchError((error) {
                                            PushNotificationMessage
                                                notification =
                                                PushNotificationMessage(
                                              title: 'Fail',
                                              body:
                                                  'Failed to update favourites',
                                            );
                                            showSimpleNotification(
                                              Container(
                                                  child:
                                                      Text(notification.body)),
                                              position:
                                                  NotificationPosition.top,
                                              background: Colors.red,
                                            );
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
                                                FieldValue.arrayRemove(
                                                    [place.id])
                                          }).catchError((error) {
                                            PushNotificationMessage
                                                notification =
                                                PushNotificationMessage(
                                              title: 'Fail',
                                              body:
                                                  'Failed to update favourites',
                                            );
                                            showSimpleNotification(
                                              Container(
                                                  child:
                                                      Text(notification.body)),
                                              position:
                                                  NotificationPosition.top,
                                              background: Colors.red,
                                            );
                                          });
                                        });
                                      },
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        location: LatLng(place.lat, place.lon),
                      ),
                    ),
                    icon: thisPinLocationIcon,
                  )
                : Marker(
                    markerId: MarkerId(cluster.getId()),
                    position: cluster.location,
                    onTap: () {
                      print('OLD CLUSTER');
                      cluster.items.forEach((p) => print(p));
                    },
                    icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
                        text: cluster.isMultiple
                            ? cluster.count.toString()
                            : null),
                  );

        //   cluster.items.forEach((place) async {
        //     BitmapDescriptor thisPinLocationIcon =
        //         await BitmapDescriptor.fromAssetImage(
        //             ImageConfiguration(devicePixelRatio: 2.5), categoryLine);
        // thisMarker = Marker(
        //   markerId: MarkerId(place.name),
        //   position: LatLng(place.lat, place.lon),
        //   onTap: () => _onTap(
        //     PointObject(
        //       child: Container(
        //         color: cardColor,
        //         child: Column(
        //           children: <Widget>[
        //             SizedBox(
        //               height: 40,
        //             ),
        //             Text(
        //               place.name,
        //               overflow: TextOverflow.ellipsis,
        //               style: GoogleFonts.montserrat(
        //                 textStyle: TextStyle(
        //                   color: whiteColor,
        //                   fontSize: 20,
        //                   fontWeight: FontWeight.bold,
        //                 ),
        //               ),
        //             ),
        //             SizedBox(
        //               height: 10,
        //             ),
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 Text(
        //                   place.by != null ? place.by : 'By',
        //                   overflow: TextOverflow.ellipsis,
        //                   maxLines: 1,
        //                   style: GoogleFonts.montserrat(
        //                     textStyle: TextStyle(
        //                       color: whiteColor,
        //                       fontSize: 17,
        //                     ),
        //                   ),
        //                 ),
        //                 SizedBox(
        //                   width: 10,
        //                 ),
        //                 categoryIcon,
        //               ],
        //             ),
        //             SizedBox(
        //               height: 20,
        //             ),
        //             Padding(
        //               padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        //               child: Row(
        //                 children: [
        //                   Row(
        //                     children: [
        //                       Icon(
        //                         Icons.star,
        //                         color: whiteColor,
        //                       ),
        //                       SizedBox(
        //                         width: 7,
        //                       ),
        //                       Text(
        //                         rating.toStringAsFixed(1) + '/5',
        //                         overflow: TextOverflow.ellipsis,
        //                         maxLines: 2,
        //                         style: GoogleFonts.montserrat(
        //                           textStyle: TextStyle(
        //                             color: whiteColor,
        //                             fontSize: 15,
        //                           ),
        //                         ),
        //                       )
        //                     ],
        //                   ),
        //                   SizedBox(
        //                     width: 10,
        //                   ),
        //                   Expanded(
        //                     child: RoundedButton(
        //                       pw: 60,
        //                       ph: 40,
        //                       text: 'Book',
        //                       press: () {
        //                         setState(() {
        //                           loading = true;
        //                         });
        //                         Navigator.push(
        //                             context,
        //                             SlideRightRoute(
        //                               page: PlaceScreen(
        //                                 data: {
        //                                   'name': place.name, //0
        //                                   'description':
        //                                       place.description, //1
        //                                   'by': place.by, //2
        //                                   'lat': place.lat, //3
        //                                   'lon': place.lon, //4
        //                                   'images': place.images, //5
        //                                   'services': place.services,
        //                                   'rates': place.rates,
        //                                   'category': place.category, //6
        //                                   'id': place.id, //7
        //                                 },
        //                               ),
        //                             ));
        //                         setState(() {
        //                           loading = false;
        //                         });
        //                       },
        //                       color: whiteColor,
        //                       textColor: darkPrimaryColor,
        //                     ),
        //                   ),
        //                   LabelButton(
        //                     isC: false,
        //                     reverse: FirebaseFirestore.instance
        //                         .collection('users')
        //                         .doc(FirebaseAuth.instance.currentUser.uid),
        //                     containsValue: place.id,
        //                     color1: Colors.red,
        //                     color2: lightPrimaryColor,
        //                     ph: 45,
        //                     pw: 45,
        //                     size: 40,
        //                     onTap: () {
        //                       setState(() {
        //                         FirebaseFirestore.instance
        //                             .collection('users')
        //                             .doc(FirebaseAuth
        //                                 .instance.currentUser.uid)
        //                             .update({
        //                           'favourites':
        //                               FieldValue.arrayUnion([place.id])
        //                         }).catchError((error) {
        //                           PushNotificationMessage notification =
        //                               PushNotificationMessage(
        //                             title: 'Fail',
        //                             body: 'Failed to update favourites',
        //                           );
        //                           showSimpleNotification(
        //                             Container(
        //                                 child: Text(notification.body)),
        //                             position: NotificationPosition.top,
        //                             background: Colors.red,
        //                           );
        //                         });
        //                       });
        //                     },
        //                     onTap2: () {
        //                       setState(() {
        //                         FirebaseFirestore.instance
        //                             .collection('users')
        //                             .doc(FirebaseAuth
        //                                 .instance.currentUser.uid)
        //                             .update({
        //                           'favourites':
        //                               FieldValue.arrayRemove([place.id])
        //                         }).catchError((error) {
        //                           PushNotificationMessage notification =
        //                               PushNotificationMessage(
        //                             title: 'Fail',
        //                             body: 'Failed to update favourites',
        //                           );
        //                           showSimpleNotification(
        //                             Container(
        //                                 child: Text(notification.body)),
        //                             position: NotificationPosition.top,
        //                             background: Colors.red,
        //                           );
        //                         });
        //                       });
        //                     },
        //                   )
        //                 ],
        //               ),
        //             )
        //           ],
        //         ),
        //       ),
        //       location: LatLng(place.lat, place.lon),
        //     ),
        //   ),
        //   icon: thisPinLocationIcon,
        // );
        //   });
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String text}) async {
    assert(size != null);

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.red;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
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
