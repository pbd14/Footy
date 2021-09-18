import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/PushNotificationMessage.dart';
import 'package:flutter_complete_guide/Screens/PlaceScreen/components/service_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/widgets/label_button.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../constants.dart';

// ignore: must_be_immutable
class PlaceScreen extends StatefulWidget {
  String placeId;
  PlaceScreen({Key key, this.placeId}) : super(key: key);
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  // ignore: unused_field
  double _height;
  // ignore: unused_field
  double _width;
  bool loading = true;
  double duration = 0;
  double price = 0;
  double rating = 0;
  double ratingSum = 0;

  bool verified = false;
  bool loading1 = false;
  bool verifying = false;

  List imgList = [];
  DocumentSnapshot place;

  Future<void> prepare() async {
    place = await FirebaseFirestore.instance
        .collection('locations')
        .doc(widget.placeId)
        .get();
    for (String img in place.data()['images']) {
      imgList.add(img);
    }
    if (place.data()['rates'] != null) {
      if (place.data()['rates'].length != 0) {
        for (var rate in place.data()['rates'].values) {
          ratingSum += rate;
        }
        rating = ratingSum / place.data()['rates'].length;
      }
    }
    if (this.mounted) {
      setState(() {
        loading = false;
      });
    } else {
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
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: darkColor,
              iconTheme: IconThemeData(color: primaryColor),
              title: Text(
                'Info',
                textScaleFactor: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                      color: whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w300),
                ),
              ),
              centerTitle: true,
            ),
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: size.height * 0.3,
                  backgroundColor: whiteColor,
                  floating: false,
                  pinned: false,
                  snap: false,
                  automaticallyImplyLeading: false,
                  flexibleSpace: CarouselSlider(
                    options: CarouselOptions(),
                    items: imgList
                        .map((item) => Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        height: 200,
                                        width: size.width,
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.none,
                                          height: 100,
                                          width: 100,
                                          placeholder: (context, url) =>
                                              Container(
                                            height: 50,
                                            width: 50,
                                            child: Transform.scale(
                                              scale: 0.1,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                backgroundColor: primaryColor,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(primaryColor),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error,
                                            color: primaryColor,
                                          ),
                                          imageUrl: item,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            // Container(
                            //       child: Center(
                            //           child: Align(
                            //         alignment: Alignment.topCenter,
                            //         child: Image.network(
                            //           item,
                            //           fit: BoxFit.cover,
                            //           width: size.width,
                            //           loadingBuilder: (BuildContext context,
                            //               Widget child,
                            //               ImageChunkEvent loadingProgress) {
                            //             if (loadingProgress == null) return child;
                            //             return Center(
                            //               child: CircularProgressIndicator(
                            //                 backgroundColor: whiteColor,
                            //                 value: loadingProgress
                            //                             .expectedTotalBytes !=
                            //                         null
                            //                     ? loadingProgress
                            //                             .cumulativeBytesLoaded /
                            //                         loadingProgress
                            //                             .expectedTotalBytes
                            //                     : null,
                            //               ),
                            //             );
                            //           },
                            //         ),
                            //       )),
                            //     ))
                            )
                        .toList(),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Text(
                                place.data()['name'],
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: darkColor,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              place.data()['description'],
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: darkColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'By ' + place.data()['by'],
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: darkColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.star,
                                  color: darkPrimaryColor,
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
                                      color: darkPrimaryColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                LabelButton(
                                  isC: false,
                                  reverse: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser.uid),
                                  containsValue: place.data()['id'],
                                  color1: Colors.red,
                                  color2: lightPrimaryColor,
                                  ph: 45,
                                  pw: 45,
                                  size: 30,
                                  onTap: () {
                                    setState(() {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(FirebaseAuth
                                              .instance.currentUser.uid)
                                          .update({
                                        'favourites': FieldValue.arrayUnion(
                                            [place.data()['id']])
                                      }).catchError((error) {
                                        PushNotificationMessage notification =
                                            PushNotificationMessage(
                                          title: 'Fail',
                                          body: 'Failed to update favourites',
                                        );
                                        showSimpleNotification(
                                          Container(
                                              child: Text(notification.body)),
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
                                          .doc(FirebaseAuth
                                              .instance.currentUser.uid)
                                          .update({
                                        'favourites': FieldValue.arrayRemove(
                                            [place.data()['id']])
                                      }).catchError((error) {
                                        PushNotificationMessage notification =
                                            PushNotificationMessage(
                                          title: 'Fail',
                                          body: 'Failed to update favourites',
                                        );
                                        showSimpleNotification(
                                          Container(
                                              child: Text(notification.body)),
                                          position: NotificationPosition.top,
                                          background: Colors.red,
                                        );
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                          ]),
                    ),
                    Center(
                      child: Text(
                        'Services',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: darkColor,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    for (Map service in place.data()['services'])
                      TextButton(
                        onPressed: () {
                          setState(() {
                            loading = true;
                          });
                          Navigator.push(
                            context,
                            SlideRightRoute(
                              page: ServiceScreen(
                                data: service,
                                serviceId: service['id'],
                                placeId: place.data()['id'],
                              ),
                            ),
                          );
                          setState(() {
                            loading = false;
                          });
                        },
                        child: Card(
                          color: darkPrimaryColor,
                          child: ListTile(
                            title: Text(
                              service['name'],
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: whiteColor,
                                ),
                              ),
                            ),
                            subtitle: Text(
                              'UZS per minute ' + service['spm'].toString(),
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: whiteColor,
                                ),
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward,
                              color: whiteColor,
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 15,
                    ),
                  ]),
                ),
              ],
            ),
          );
    // PageView(
    //   controller: controller,
    //   scrollDirection: Axis.vertical,
    //   children: [
    //     PlaceScreen1(
    //       data: widget.data,
    //     ),
    //     PlaceScreen2(
    //       data: widget.data,
    //     ),
    //   ],
    // );
  }
}
