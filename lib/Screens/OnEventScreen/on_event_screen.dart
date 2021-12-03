import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/LanguageData.dart';
import 'package:flutter_complete_guide/Models/Place.dart';
import 'package:flutter_complete_guide/Models/PushNotificationMessage.dart';
import 'package:flutter_complete_guide/Screens/MapScreen/map_screen.dart';
import 'package:flutter_complete_guide/Services/languages/languages.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:flutter_complete_guide/widgets/rounded_text_input.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

class OnEventScreen extends StatefulWidget {
  final String bookingId;
  OnEventScreen({Key key, this.bookingId}) : super(key: key);
  @override
  _OnEventScreenState createState() => _OnEventScreenState();
}

class _OnEventScreenState extends State<OnEventScreen> {
  bool loading = true;
  double initRat = 3;
  String reason = '';
  // ignore: non_constant_identifier_names
  var cancellations_num = 0;
  DocumentSnapshot booking;
  DocumentSnapshot place;
  DocumentSnapshot user;
  DocumentSnapshot company;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<DocumentSnapshot> bookingSubscr;

  @override
  void dispose() {
    bookingSubscr.cancel();
    super.dispose();
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    bookingSubscr.cancel();
    prepare();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  Future<void> prepare() async {
    user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    bookingSubscr = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots()
        .listen((thisBooking) async {
      place = await FirebaseFirestore.instance
          .collection('locations')
          .doc(thisBooking.data()['placeId'])
          .get();
      company = await FirebaseFirestore.instance
          .collection('companies')
          .doc(place.data()['owner'])
          .get();
      if (this.mounted) {
        setState(() {
          if (user.data()['cancellations_num'] != null) {
            cancellations_num = user.data()['cancellations_num'];
          }
          booking = thisBooking;
          if (place.data()['rates'] != null) {
            if (place.data()['rates'].containsKey(thisBooking.id)) {
              initRat = place.data()['rates'][thisBooking.id];
            }
          }
          loading = false;
        });
      } else {
        if (user.data()['cancellations_num'] != null) {
          cancellations_num = user.data()['cancellations_num'];
        }
        booking = thisBooking;
        if (place.data()['rates'] != null) {
          if (place.data()['rates'].containsKey(thisBooking.id)) {
            initRat = place.data()['rates'][thisBooking.id];
          }
        }
        loading = false;
      }
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
        : RefreshIndicator(
            onRefresh: _refresh,
            child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                backgroundColor: darkColor,
                iconTheme: IconThemeData(
                  color: primaryColor,
                ),
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
                      expandedHeight: size.height * 0.2,
                      backgroundColor: darkPrimaryColor,
                      automaticallyImplyLeading: false,
                      floating: false,
                      pinned: false,
                      snap: false,
                      flexibleSpace: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              place != null
                                  ? Place.fromSnapshot(place)
                                      .services
                                      .where((service) {
                                      if (service['id'] ==
                                          booking.data()['serviceId']) {
                                        return true;
                                      } else {
                                        return false;
                                      }
                                    }).first['name']
                                  : 'Service',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: whiteColor,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              place != null
                                  ? Place.fromSnapshot(place).name
                                  : 'Place',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: whiteColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      // SizedBox(
                      //   height: 20,
                      // ),
                      // CardW(
                      //   width: 0.9,
                      //   ph: 300,
                      //   child: Center(
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: <Widget>[
                      //         Text(
                      //           DateFormat.yMMMd()
                      //               .format(DateTime.parse(
                      //                   Booking.fromSnapshot(widget.booking)
                      //                       .date))
                      //               .toString(),
                      //           style: GoogleFonts.montserrat(
                      //             textStyle: TextStyle(
                      //               color: darkPrimaryColor,
                      //               fontSize: 20,
                      //             ),
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           height: 5,
                      //         ),
                      //         Text(
                      //           'From: ' +
                      //               Booking.fromSnapshot(widget.booking).from,
                      //           style: GoogleFonts.montserrat(
                      //             textStyle: TextStyle(
                      //               color: darkPrimaryColor,
                      //               fontSize: 20,
                      //             ),
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           height: 5,
                      //         ),
                      //         Text(
                      //           'To: ' + Booking.fromSnapshot(widget.booking).to,
                      //           style: GoogleFonts.montserrat(
                      //             textStyle: TextStyle(
                      //               color: darkPrimaryColor,
                      //               fontSize: 20,
                      //             ),
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           height: 5,
                      //         ),
                      //         Text(
                      //           Booking.fromSnapshot(widget.booking)
                      //                   .price
                      //                   .toString() +
                      //               " So'm ",
                      //           style: GoogleFonts.montserrat(
                      //             textStyle: TextStyle(
                      //               color: darkPrimaryColor,
                      //               fontSize: 20,
                      //             ),
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           height: 5,
                      //         ),
                      //         SizedBox(
                      //           width: size.width * 0.1,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 20,
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

                      Container(
                        width: size.width * 0.8,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 11,
                          margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  CupertinoIcons.info_circle,
                                  color: darkPrimaryColor,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      booking.data()['status'] ==
                                                  'unfinished' ||
                                              booking.data()['status'] ==
                                                  'verification_needed'
                                          ? Text(
                                              Languages.of(context)
                                                  .oeScreenNotStarted,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: darkColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      booking.data()['status'] == 'in process'
                                          ? Text(
                                              Languages.of(context)
                                                  .oeScreenInProcess,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: greenColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      booking.data()['status'] == 'unpaid'
                                          ? Text(
                                              Languages.of(context)
                                                  .oeScreenMakePayment,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 10,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      booking.data()['status'] == 'unpaid' &&
                                              booking.data()[
                                                      'payment_method'] ==
                                                  'octo'
                                          ? Text(
                                              Languages.of(context)
                                                      .oeScreenMakePaymentWith +
                                                  " " +
                                                  Languages.of(context)
                                                      .serviceScreenCreditCard,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 8,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(
                                        height:
                                            booking.data()['status'] == 'unpaid'
                                                ? 10
                                                : 0,
                                      ),
                                      booking.data()['status'] == 'unpaid'
                                          ? Center(
                                              child: Text(
                                                booking
                                                        .data()['price']
                                                        .toString() +
                                                    ' UZS',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 15,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: darkColor,
                                                    fontSize: 25,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      booking.data()['status'] == 'finished'
                                          ? Text(
                                              Languages.of(context)
                                                  .oeScreenEnded,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: darkPrimaryColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        width: size.width * 0.8,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 10,
                          margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (String phone in company.data()['phones'])
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        phone,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          await launch("tel:" + phone);
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: primaryColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: darkPrimaryColor
                                                    .withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 7,
                                                offset: Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            CupertinoIcons.phone_fill,
                                            color: whiteColor,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      Container(
                        width: size.width * 0.8,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 10,
                          margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat.yMMMd()
                                      .format(booking
                                          .data()['timestamp_date']
                                          .toDate())
                                      .toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  booking.data()['from'] +
                                      ' - ' +
                                      booking.data()['to'],
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  Languages.of(context).oeScreenOverallPrice +
                                      ': ' +
                                      booking.data()['price'].toString() +
                                      " UZS",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  Languages.of(context).oeScreenStatus +
                                              ': ' +
                                              booking.data()['status'] ==
                                          'unfinished'
                                      ? Languages.of(context)
                                          .historyScreenUpcoming
                                      : booking.data()['status'] == 'unpaid'
                                          ? Languages.of(context)
                                              .historyScreenUnpaid
                                          : booking.data()['status'] ==
                                                  'finished'
                                              ? Languages.of(context)
                                                  .oeScreenEnded
                                              : booking.data()['status'] ==
                                                      'in process'
                                                  ? Languages.of(context)
                                                      .oeScreenInProcess
                                                  : booking.data()['status'] ==
                                                          'verification_needed'
                                                      ? Languages.of(context)
                                                          .historyScreenVerificationNeeded
                                                      : booking
                                                          .data()['status'],
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: booking.data()['status'] ==
                                              'unfinished'
                                          ? darkColor
                                          : Colors.red,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                booking.data()['payment_method'] == 'cash'
                                    ? Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: booking.data()[
                                                        'payment_method'] ==
                                                    'cash'
                                                ? darkPrimaryColor
                                                : whiteColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: booking.data()[
                                                            'payment_method'] ==
                                                        'cash'
                                                    ? darkPrimaryColor
                                                        .withOpacity(0.5)
                                                    : darkColor
                                                        .withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 7,
                                                offset: Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            shape: BoxShape.rectangle,
                                          ),
                                          width: 50,
                                          height: 50,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                CupertinoIcons.money_dollar,
                                                size: 20,
                                                color: booking.data()[
                                                            'payment_method'] ==
                                                        'cash'
                                                    ? whiteColor
                                                    : darkPrimaryColor,
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                Languages.of(context)
                                                    .serviceScreenCash,
                                                maxLines: 3,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: booking.data()[
                                                                'payment_method'] ==
                                                            'cash'
                                                        ? whiteColor
                                                        : darkPrimaryColor,
                                                    fontSize: 8,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                booking.data()['payment_method'] == 'octo'
                                    ? Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: booking.data()[
                                                        'payment_method'] ==
                                                    'octo'
                                                ? darkPrimaryColor
                                                : whiteColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: booking.data()[
                                                            'payment_method'] ==
                                                        'octo'
                                                    ? darkPrimaryColor
                                                        .withOpacity(0.5)
                                                    : darkColor
                                                        .withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 7,
                                                offset: Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            shape: BoxShape.rectangle,
                                          ),
                                          width: 75,
                                          height: 75,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                CupertinoIcons.creditcard,
                                                size: 30,
                                                color: booking.data()[
                                                            'payment_method'] ==
                                                        'octo'
                                                    ? whiteColor
                                                    : darkPrimaryColor,
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                Languages.of(context)
                                                    .serviceScreenCreditCard,
                                                maxLines: 3,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: booking.data()[
                                                                'payment_method'] ==
                                                            'octo'
                                                        ? whiteColor
                                                        : darkPrimaryColor,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      DateTime.now().isBefore(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      booking.data()['deadline'].seconds *
                                              1000 -
                                          3600000)) &&
                              cancellations_num < 6
                          ? Container(
                              width: size.width * 0.8,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                elevation: 11,
                                margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        CupertinoIcons.info_circle,
                                        color: darkPrimaryColor,
                                        size: 30,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Languages.of(context)
                                                      .oeScreenCanCancel +
                                                  ' :' +
                                                  cancellations_num.toString(),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 10,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: darkPrimaryColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Center(
                                              child: RoundedButton(
                                                pw: 100,
                                                ph: 45,
                                                text: Languages.of(context)
                                                    .oeScreenCancel,
                                                press: () {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(Languages
                                                                    .of(context)
                                                                .oeScreenCancel +
                                                            '?'),
                                                        content: Text(Languages
                                                                    .of(context)
                                                                .oeScreenQuestionCancel +
                                                            '?'),
                                                        scrollable: true,
                                                        actions: <Widget>[
                                                          Form(
                                                            key: _formKey,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                RoundedTextInput(
                                                                  validator: (val) => val
                                                                              .length >=
                                                                          5
                                                                      ? null
                                                                      : Languages.of(context)
                                                                              .oeScreenMinCharacters +
                                                                          ': 5',
                                                                  hintText: Languages.of(
                                                                          context)
                                                                      .oeScreenReason,
                                                                  length: 500,
                                                                  type: TextInputType
                                                                      .multiline,
                                                                  onChanged:
                                                                      (value) {
                                                                    this.reason =
                                                                        value;
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                    height: 20),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              if (_formKey
                                                                  .currentState
                                                                  .validate()) {
                                                                setState(() {
                                                                  loading =
                                                                      true;
                                                                });
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'users')
                                                                    .doc(FirebaseAuth
                                                                        .instance
                                                                        .currentUser
                                                                        .uid)
                                                                    .update({
                                                                  'cancellations_num':
                                                                      cancellations_num +
                                                                          1,
                                                                }).catchError(
                                                                        (error) {
                                                                  setState(() {
                                                                    loading =
                                                                        false;
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          false);
                                                                  PushNotificationMessage
                                                                      notification =
                                                                      PushNotificationMessage(
                                                                    title:
                                                                        'Fail',
                                                                    body:
                                                                        'Failed to cancel booking',
                                                                  );
                                                                  showSimpleNotification(
                                                                    Container(
                                                                        child: Text(
                                                                            notification.body)),
                                                                    position:
                                                                        NotificationPosition
                                                                            .top,
                                                                    background:
                                                                        Colors
                                                                            .red,
                                                                  );
                                                                });

                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'bookings')
                                                                    .doc(booking
                                                                        .id)
                                                                    .delete()
                                                                    .catchError(
                                                                        (error) {
                                                                  setState(() {
                                                                    loading =
                                                                        false;
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          false);
                                                                  PushNotificationMessage
                                                                      notification =
                                                                      PushNotificationMessage(
                                                                    title:
                                                                        'Fail',
                                                                    body:
                                                                        'Failed to cancel booking',
                                                                  );
                                                                  showSimpleNotification(
                                                                    Container(
                                                                        child: Text(
                                                                            notification.body)),
                                                                    position:
                                                                        NotificationPosition
                                                                            .top,
                                                                    background:
                                                                        Colors
                                                                            .red,
                                                                  );
                                                                });
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'users')
                                                                    .doc(company
                                                                            .data()[
                                                                        'owner'])
                                                                    .update({
                                                                  'notifications_business':
                                                                      FieldValue
                                                                          .arrayUnion([
                                                                    {
                                                                      'seen':
                                                                          false,
                                                                      'type':
                                                                          'booking_canceled',
                                                                      // 'bookingId':
                                                                      //     booking.id,
                                                                      'title':
                                                                          'Canceled',
                                                                      'text': 'Client has canceled the booking (' +
                                                                          place.data()[
                                                                              'name'] +
                                                                          ' ' +
                                                                          DateFormat.yMMMd()
                                                                              .format(booking.data()['timestamp_date'].toDate())
                                                                              .toString() +
                                                                          ')' +
                                                                          '. Reason: ' +
                                                                          reason +
                                                                          '. Contact: ' +
                                                                          FirebaseAuth.instance.currentUser.phoneNumber,
                                                                      'companyName':
                                                                          company
                                                                              .data()['name'],
                                                                      'date': DateTime
                                                                          .now(),
                                                                    }
                                                                  ])
                                                                }).catchError(
                                                                        (error) {
                                                                  setState(() {
                                                                    loading =
                                                                        false;
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          false);
                                                                  PushNotificationMessage
                                                                      notification =
                                                                      PushNotificationMessage(
                                                                    title:
                                                                        'Fail',
                                                                    body:
                                                                        'Failed to cancel booking',
                                                                  );
                                                                  showSimpleNotification(
                                                                    Container(
                                                                        child: Text(
                                                                            notification.body)),
                                                                    position:
                                                                        NotificationPosition
                                                                            .top,
                                                                    background:
                                                                        Colors
                                                                            .red,
                                                                  );
                                                                });

                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                                Navigator.pop(
                                                                    context);
                                                                PushNotificationMessage
                                                                    notification =
                                                                    PushNotificationMessage(
                                                                  title:
                                                                      'Canceled',
                                                                  body:
                                                                      'The booking was canceled',
                                                                );
                                                                showSimpleNotification(
                                                                  Container(
                                                                      child: Text(
                                                                          notification
                                                                              .body)),
                                                                  position:
                                                                      NotificationPosition
                                                                          .top,
                                                                  background:
                                                                      Colors
                                                                          .red,
                                                                );
                                                                setState(() {
                                                                  loading =
                                                                      false;
                                                                });
                                                              }
                                                            },
                                                            child: const Text(
                                                              'Yes',
                                                              style: TextStyle(
                                                                  color:
                                                                      primaryColor),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false),
                                                            child: const Text(
                                                              'No',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                color: Colors.red,
                                                textColor: whiteColor,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 20,
                      ),

                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        width: size.width * 0.9,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 10,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                booking.data()['status'] != 'unfinished'
                                    ? Container(
                                        child: RatingBar.builder(
                                          initialRating: initRat,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemPadding: EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          itemBuilder: (context, _) => Icon(
                                            CupertinoIcons.star_fill,
                                            color: Colors.yellow,
                                          ),
                                          onRatingUpdate: (rating) {
                                            var dataBooking = booking.id;
                                            FirebaseFirestore.instance
                                                .collection('locations')
                                                .doc(Place.fromSnapshot(place)
                                                    .id)
                                                .update({
                                              'rates.$dataBooking': rating,
                                            });
                                            FirebaseFirestore.instance
                                                .collection('bookings')
                                                .doc(booking.id)
                                                .update({'isRated': true});
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              _scaffoldKey.currentState
                                                  .showSnackBar(SnackBar(
                                                backgroundColor:
                                                    darkPrimaryColor,
                                                content: Text(
                                                  'Rating was saved',
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: whiteColor,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                              ));
                                            });
                                          },
                                        ),
                                      )
                                    : Container(),
                                IconButton(
                                  iconSize: 30,
                                  icon: Icon(
                                    CupertinoIcons.map_pin_ellipse,
                                    color: darkPrimaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: MapScreen(
                                          data: {
                                            'lat':
                                                Place.fromSnapshot(place).lat,
                                            'lon': Place.fromSnapshot(place).lon
                                          },
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
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          );
  }
}
