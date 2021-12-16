import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Screens/OnEventScreen/on_event_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/Services/languages/locale_constant.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';

class ProfileScreen1 extends StatefulWidget {
  @override
  _ProfileScreen1State createState() => _ProfileScreen1State();
}

class _ProfileScreen1State extends State<ProfileScreen1> {
  bool loading = true;

  List notifs = [];
  List<bool> isSeenList = [];
  RemoteConfig remoteConfig = RemoteConfig.instance;
  SharedPreferences _prefs;
  bool remoteConfigUpdated;
  String langCode = 'en';

  DocumentSnapshot user;

  // StreamSubscription<DocumentSnapshot> notifications;

  String getDate(int millisecondsSinceEpoch) {
    String date = '';
    DateTime d = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    if (d.year == DateTime.now().year) {
      if (d.month == DateTime.now().month) {
        if (d.day == DateTime.now().day) {
          date = 'today';
        } else {
          int n = DateTime.now().day - d.day;
          switch (n) {
            case 1:
              date = 'yesterday';
              break;
            case 2:
              date = '2 days ago';
              break;
            case 3:
              date = n.toString() + ' days ago';
              break;
            case 4:
              date = n.toString() + ' days ago';
              break;
            default:
              date = n.toString() + ' days ago';
          }
        }
      } else {
        int n = DateTime.now().month - d.month;
        switch (n) {
          case 1:
            date = 'last month';
            break;
          case 2:
            date = n.toString() + ' months ago';
            break;
          case 3:
            date = n.toString() + ' months ago';
            break;
          case 4:
            date = n.toString() + ' months ago';
            break;
          default:
            date = n.toString() + ' months ago';
        }
      }
    } else {
      int n = DateTime.now().year - d.year;
      switch (n) {
        case 1:
          date = 'last year';
          break;
        case 2:
          date = n.toString() + ' years ago';
          break;
        case 3:
          date = n.toString() + ' years ago';
          break;
        case 4:
          date = n.toString() + ' years ago';
          break;
        default:
          date = n.toString() + ' years ago';
      }
    }
    return date;
  }

  Future<void> prepare() async {
    user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    _prefs = await SharedPreferences.getInstance();
    remoteConfigUpdated = await remoteConfig.fetchAndActivate();

    if (user.exists) {
      if (user.data()['notifications'] != null) {
        if (user.data()['notifications'].length != 0) {
          if (user.data()['notifications'].length > 50) {
            for (int i = user.data()['notifications'].length - 1;
                i >= user.data()['notifications'].length - 50;
                i--) {
              if (this.mounted) {
                setState(() {
                  notifs.add(user.data()['notifications'][i]);
                });
              } else {
                notifs.add(user.data()['notifications'][i]);
              }
            }
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser.uid)
                .update({
              'notifications': notifs.reversed,
            });
          } else {
            for (Map notif in user.data()['notifications'].reversed) {
              if (this.mounted) {
                setState(() {
                  notifs.add(notif);
                });
              } else {
                notifs.add(notif);
              }
            }
          }
        }
      }
    }

    for (Map notif in notifs) {
      isSeenList.add(notif['seen']);
      // Map middleNotif = notif;
      // if (!middleNotif['seen']) {
      //   middleNotif['seen'] = true;
      // }
      // updatedNotifications.add(middleNotif);
    }
    if (this.mounted) {
      setState(() {
        loading = false;
        langCode = _prefs.getString(prefSelectedLanguageCode) ?? "en";
      });
    } else {
      loading = false;
      langCode = _prefs.getString(prefSelectedLanguageCode) ?? "en";
    }
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  List updatedNotifsFunction() {
    List updatedNotifications = [];
    for (Map notif in notifs) {
      notif['seen'] = isSeenList[notifs.indexOf(notif)];
      updatedNotifications.add(notif);
    }

    return updatedNotifications.reversed.toList();
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    notifs = [];
    isSeenList = [];
    prepare();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : RefreshIndicator(
            onRefresh: _refresh,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Scaffold(
                body: ListView(
                  children: [
                      ExpansionPanelList(
                        dividerColor: primaryColor,
                        animationDuration: Duration(seconds: 1),
                        elevation: 1,
                        expandedHeaderPadding: EdgeInsets.all(0),
                        expansionCallback: (index, isOpen) {
                          if (!isOpen) {
                            setState(() {
                              isSeenList[index] = true;
                            });
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .update(
                                    {'notifications': updatedNotifsFunction()});
                          }
                        },
                        children: [
                          for (Map notif in notifs)
                            // Offer accepted
                            notif['type'] == 'notifications_offer_accepted'
                                ? ExpansionPanel(
                                    backgroundColor: darkPrimaryColor,
                                    canTapOnHeader: true,
                                    isExpanded:
                                        isSeenList[notifs.indexOf(notif)],
                                    headerBuilder: (context, isOpen) {
                                      return !isOpen
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: Container(
                                                    child: Text(
                                                      jsonDecode(remoteConfig
                                                              .getValue(
                                                                  notif['type'])
                                                              .asString())[
                                                          langCode]['title'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: whiteColor,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Center(
                                                  child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: whiteColor),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Center(
                                              child: Container(
                                                margin: EdgeInsets.all(10),
                                                child: Text(
                                                  jsonDecode(
                                                          remoteConfig
                                                              .getValue(
                                                                  notif['type'])
                                                              .asString())[
                                                      langCode]['title'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: whiteColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                    },
                                    body: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        setState(() {
                                          loading = true;
                                        });
                                        Navigator.push(
                                          context,
                                          SlideRightRoute(
                                              page: OnEventScreen(
                                            bookingId: notif['bookingId'],
                                          )),
                                        );
                                        setState(() {
                                          loading = false;
                                        });
                                      },
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                jsonDecode(remoteConfig
                                                        .getValue(notif['type'])
                                                        .asString())[langCode]
                                                    ['text'],
                                                maxLines: 20,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      color: whiteColor,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                'Company: ' +
                                                    notif['companyName'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      color: whiteColor,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                getDate(notif['date']
                                                    .millisecondsSinceEpoch),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      color: whiteColor,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                // Booking rejected
                                : notif['type'] ==
                                        'notifications_offer_rejected'
                                    ? ExpansionPanel(
                                        backgroundColor: Colors.red,
                                        canTapOnHeader: true,
                                        isExpanded:
                                            isSeenList[notifs.indexOf(notif)],
                                        headerBuilder: (context, isOpen) {
                                          return !isOpen
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Container(
                                                        child: Text(
                                                          jsonDecode(remoteConfig
                                                                  .getValue(notif[
                                                                      'type'])
                                                                  .asString())[
                                                              langCode]['title'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Center(
                                                      child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color:
                                                                primaryColor),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Center(
                                                  child: Container(
                                                    margin: EdgeInsets.all(10),
                                                    child: Text(
                                                      jsonDecode(remoteConfig
                                                              .getValue(
                                                                  notif['type'])
                                                              .asString())[
                                                          langCode]['title'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: whiteColor,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                        },
                                        body: CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {},
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    jsonDecode(
                                                            remoteConfig
                                                                .getValue(notif[
                                                                    'type'])
                                                                .asString())[
                                                        langCode]['text'],
                                                    maxLines: 20,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                          color: whiteColor,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Company: ' +
                                                        notif['companyName'],
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                          color: whiteColor,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    getDate(notif['date']
                                                        .millisecondsSinceEpoch),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                          color: whiteColor,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )

                                    // Deadline passed
                                    : notif['type'] ==
                                            'notifications_deadline_passed'
                                        ? ExpansionPanel(
                                            backgroundColor: Colors.red,
                                            canTapOnHeader: true,
                                            isExpanded: isSeenList[
                                                notifs.indexOf(notif)],
                                            headerBuilder: (context, isOpen) {
                                              return !isOpen
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Center(
                                                          child: Container(
                                                            child: Text(
                                                              jsonDecode(remoteConfig
                                                                      .getValue(
                                                                          notif[
                                                                              'type'])
                                                                      .asString())[
                                                                  langCode]['title'],
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                textStyle:
                                                                    TextStyle(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Center(
                                                          child: Container(
                                                            height: 20,
                                                            width: 20,
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    primaryColor),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Center(
                                                      child: Container(
                                                        margin:
                                                            EdgeInsets.all(10),
                                                        child: Text(
                                                          jsonDecode(remoteConfig
                                                                  .getValue(notif[
                                                                      'type'])
                                                                  .asString())[
                                                              langCode]['title'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                            },
                                            body: CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {},
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        jsonDecode(remoteConfig
                                                                .getValue(notif[
                                                                    'type'])
                                                                .asString())[
                                                            langCode]['text'],
                                                        maxLines: 20,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        'Company: ' +
                                                            notif[
                                                                'companyName'],
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        getDate(notif['date']
                                                            .millisecondsSinceEpoch),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )

                                        // Custom
                                        : notif['type'] == 'custom'
                                            ? ExpansionPanel(
                                                backgroundColor: whiteColor,
                                                canTapOnHeader: true,
                                                isExpanded: isSeenList[
                                                    notifs.indexOf(notif)],
                                                headerBuilder:
                                                    (context, isOpen) {
                                                  return !isOpen
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Center(
                                                              child: Container(
                                                                child: Text(
                                                                  notif[
                                                                      'title'],
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: GoogleFonts
                                                                      .montserrat(
                                                                    textStyle:
                                                                        TextStyle(
                                                                      color:
                                                                          darkColor,
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Center(
                                                              child: Container(
                                                                height: 20,
                                                                width: 20,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color:
                                                                        primaryColor),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Center(
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Text(
                                                              notif['title'],
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                textStyle:
                                                                    TextStyle(
                                                                  color:
                                                                      darkColor,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                },
                                                body: CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () {},
                                                  child: Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            notif['text'],
                                                            maxLines: 20,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle: TextStyle(
                                                                  color:
                                                                      darkColor,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            'Company: ' +
                                                                notif[
                                                                    'companyName'],
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle: TextStyle(
                                                                  color:
                                                                      darkColor,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            getDate(notif[
                                                                    'date']
                                                                .millisecondsSinceEpoch),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle: TextStyle(
                                                                  color:
                                                                      darkColor,
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : ExpansionPanel(
                                                    headerBuilder:
                                                        (context, isOpen) =>
                                                            Container(),
                                                    body: Container(),
                                            )
                        ],
                      ),
                  ],
                ),

                // CupertinoButton(
                //   padding: EdgeInsets.zero,
                //   onPressed: () {
                //     if (notifs[index]['type'] == 'offer_accepted') {
                //       setState(() {
                //         loading = true;
                //       });
                //       Navigator.push(
                //         context,
                //         SlideRightRoute(
                //             page: OnEventScreen(
                //           bookingId: notifs[index]['bookingId'],
                //         )),
                //       );
                //       setState(() {
                //         loading = false;
                //       });
                //     }
                //   },
                //   child: Container(
                //     margin: EdgeInsets.symmetric(horizontal: 10.0),
                //     // padding: EdgeInsets.all(10),
                //     child: Card(
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(20.0),
                //       ),
                //       color: notifs[index]['type'] ==
                //               'booking_canceled'
                //           ? Colors.red
                //           : whiteColor,
                //       margin: EdgeInsets.all(5),
                //       elevation: 10,
                //       child: Padding(
                //         padding: const EdgeInsets.all(10.0),
                //         child: Container(
                //           child: Row(
                //             children: [
                //               Expanded(
                //                 child: Column(
                //                   crossAxisAlignment:
                //                       CrossAxisAlignment.start,
                //                   children: [
                //                     Text(
                //                       notifs[index]['title'],
                //                       overflow:
                //                           TextOverflow.ellipsis,
                //                       style: GoogleFonts.montserrat(
                //                         textStyle: TextStyle(
                //                           color: notifs[index]
                //                                       ['type'] ==
                //                                   'booking_canceled'
                //                               ? whiteColor
                //                               : darkColor,
                //                           fontSize: 20,
                //                           fontWeight:
                //                               FontWeight.bold,
                //                         ),
                //                       ),
                //                     ),
                //                     SizedBox(
                //                       height: 10,
                //                     ),
                //                     Text(
                //                       notifs[index]['text'],
                //                       maxLines: 20,
                //                       overflow:
                //                           TextOverflow.ellipsis,
                //                       style: GoogleFonts.montserrat(
                //                         textStyle: TextStyle(
                //                             color: notifs[index]
                //                                         ['type'] ==
                //                                     'booking_canceled'
                //                                 ? whiteColor
                //                                 : darkColor,
                //                             fontSize: 15,
                //                             fontWeight:
                //                                 FontWeight.w400),
                //                       ),
                //                     ),
                //                     SizedBox(
                //                       height: 5,
                //                     ),
                //                     Text(
                //                       'Company: ' +
                //                           notifs[index]
                //                               ['companyName'],
                //                       maxLines: 2,
                //                       overflow:
                //                           TextOverflow.ellipsis,
                //                       style: GoogleFonts.montserrat(
                //                         textStyle: TextStyle(
                //                             color: notifs[index]
                //                                         ['type'] ==
                //                                     'booking_canceled'
                //                                 ? whiteColor
                //                                 : darkColor,
                //                             fontSize: 15,
                //                             fontWeight:
                //                                 FontWeight.w400),
                //                       ),
                //                     ),
                //                     SizedBox(
                //                       height: 10,
                //                     ),
                //                     Text(
                //                       getDate(notifs[index]['date']
                //                           .millisecondsSinceEpoch),
                //                       maxLines: 2,
                //                       overflow:
                //                           TextOverflow.ellipsis,
                //                       style: GoogleFonts.montserrat(
                //                         textStyle: TextStyle(
                //                             color: notifs[index]
                //                                         ['type'] ==
                //                                     'booking_canceled'
                //                                 ? whiteColor
                //                                 : darkColor,
                //                             fontSize: 17,
                //                             fontWeight:
                //                                 FontWeight.w400),
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               SizedBox(
                //                 width: 10,
                //               ),
                //               notifs[index]['seen']
                //                   ? Container()
                //                   : Center(
                //                       child: Container(
                //                         height: 20,
                //                         width: 20,
                //                         decoration: BoxDecoration(
                //                             shape: BoxShape.circle,
                //                             color: primaryColor),
                //                       ),
                //                     ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // );
              ),
            ),
          );
  }
}
