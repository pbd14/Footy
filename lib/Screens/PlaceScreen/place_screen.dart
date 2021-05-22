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
  Map data;
  PlaceScreen({Key key, this.data}) : super(key: key);
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  // ignore: unused_field
  double _height;
  // ignore: unused_field
  double _width;
  bool loading = false;
  double duration = 0;
  double price = 0;
  double rating = 0;
  double ratingSum = 0;

  bool verified = false;
  bool loading1 = false;
  bool verifying = false;

  List imgList = [];

  @override
  void initState() {
    super.initState();
    for (String img in widget.data['images']) {
      imgList.add(img);
    }
    if (widget.data['rates'] != null) {
      if (widget.data['rates'].length != 0) {
        for (var rate in widget.data['rates'].values) {
          ratingSum += rate;
        }
        rating = ratingSum / widget.data['rates'].length;
      }
    }
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
              backgroundColor: primaryColor,
            ),
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: size.height * 0.3,
                  backgroundColor: whiteColor,
                  floating: false,
                  pinned: false,
                  snap: false,
                  flexibleSpace: CarouselSlider(
                    options: CarouselOptions(),
                    items: imgList
                        .map((item) => Container(
                              child: Center(
                                  child: Align(
                                alignment: Alignment.topCenter,
                                child: Image.network(
                                  item,
                                  fit: BoxFit.cover,
                                  width: size.width,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: whiteColor,
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              )),
                            ))
                        .toList(),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      color: whiteColor,
                      width: size.width * 0.85,
                      height: size.height * 0.55,
                      margin: EdgeInsets.fromLTRB(size.width * 0.045,
                          size.height * 0, size.width * 0.045, size.height * 0),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    widget.data['name'],
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: darkPrimaryColor,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    widget.data['description'],
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: darkPrimaryColor,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Rating',
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkPrimaryColor,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: darkPrimaryColor,
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
                                            color: darkPrimaryColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: size.width * 0.58,
                                        color: lightPrimaryColor,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'By ' + widget.data['by'],
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: darkPrimaryColor,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      LabelButton(
                                        isC: false,
                                        reverse: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(FirebaseAuth
                                                .instance.currentUser.uid),
                                        containsValue: widget.data['id'],
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
                                              'favourites':
                                                  FieldValue.arrayUnion(
                                                      [widget.data['id']])
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
                                                    child: Text(
                                                        notification.body)),
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
                                                      [widget.data['id']])
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
                                                    child: Text(
                                                        notification.body)),
                                                position:
                                                    NotificationPosition.top,
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
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Services',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: darkPrimaryColor,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    for (var service in widget.data['services'])
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
                                serviceId:
                                    widget.data['services'].indexOf(service),
                                placeId: widget.data['id'],
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
                              'Sum per minute ' + service['spm'].toString(),
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
