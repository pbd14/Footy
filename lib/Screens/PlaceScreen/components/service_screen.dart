import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Booking.dart';
import 'package:flutter_complete_guide/Models/PushNotificationMessage.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/Services/languages/languages.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../../constants.dart';

// ignore: must_be_immutable
class ServiceScreen extends StatefulWidget {
  Map data;
  String serviceId;
  String placeId;
  ServiceScreen({Key key, this.data, this.serviceId, this.placeId})
      : super(key: key);
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<ServiceScreen> {
  bool loading = false;
  double _height;
  double _width;
  double duration = 0;
  double price = 0;
  double servicePrice = 0;
  double commissionPrice = 0;

  bool verified = false;
  bool loading1 = false;
  bool verifying = false;
  bool can = true;
  bool isConnected = false;

  // ignore: unused_field
  String _setTime, _setTime2, _setDate, error;
  String _hour, _minute, _time, _dow;
  String _hour2, _minute2, _time2;
  String dateTime;
  String payment_way = '';

  List imgList = [];
  List alreadyBookings = [];

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TimeOfDay selectedTime2 = TimeOfDay(hour: 00, minute: 00);

  DocumentSnapshot place;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _timeController2 = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _timeController2.dispose();
    super.dispose();
  }

  Future<void> _verify(time1, time2) async {
    double dtime1 = selectedTime.minute + selectedTime.hour * 60.0;
    double dtime2 = selectedTime2.minute + selectedTime2.hour * 60.0;
    double dNow = DateTime.now().minute + DateTime.now().hour * 60.0;
    if (selectedDate.isBefore(DateTime.now())) {
      if (selectedDate.day != DateTime.now().day) {
        setState(() {
          error = 'Incorrect date selected';
          loading1 = false;
          verified = false;
        });
        return;
      } else {
        if (dtime1 < dNow) {
          setState(() {
            error = 'Incorrect time selected';
            loading1 = false;
            verified = false;
          });
          return;
        }
      }
    }

    if (place.data()['type'] == 'verification_needed') {
      if (selectedDate.day == DateTime.now().day &&
          selectedDate.month == DateTime.now().month &&
          selectedDate.year == DateTime.now().year) {
        if ((selectedTime.minute + selectedTime.hour * 60) -
                (DateTime.now().minute + DateTime.now().hour * 60) <
            120) {
          setState(() {
            error = 'Booking should be made 2 hours in advance for this place';
            loading1 = false;
            verified = false;
          });
          return;
        }
      }
    }

    if (dtime1 >= dtime2) {
      setState(() {
        error = 'Incorrect time selected';
        loading1 = false;
        verified = false;
      });
      return;
    } else {
      if (widget.data['vacation_days'] != null &&
          widget.data['vacation_days']
              .contains(Timestamp.fromDate(selectedDate))) {
        setState(() {
          error = 'This place is closed this day';
          loading1 = false;
          verified = false;
        });
      } else {
        if (widget.data['days'][_dow]['status'] == 'closed') {
          setState(() {
            error = 'This place is closed this day';
            loading1 = false;
            verified = false;
          });
        } else {
          TimeOfDay placeTo = TimeOfDay.fromDateTime(
              DateFormat.Hm().parse(widget.data['days'][_dow]['to']));
          TimeOfDay placeFrom = TimeOfDay.fromDateTime(
              DateFormat.Hm().parse(widget.data['days'][_dow]['from']));
          double dplaceTo = placeTo.minute + placeTo.hour * 60.0;
          double dplaceFrom = placeFrom.minute + placeFrom.hour * 60.0;
          if (dtime1 < dplaceFrom || dtime2 < dplaceFrom) {
            setState(() {
              error = 'Too early';
              loading1 = false;
              verified = false;
            });
            return;
          }
          if (dtime1 > dplaceTo || dtime2 > dplaceTo) {
            setState(() {
              error = 'Too late';
              loading1 = false;
              verified = false;
            });
            return;
          }
          if (dtime1 >= dplaceFrom && dtime2 <= dplaceTo) {
            var data = await FirebaseFirestore.instance
                .collection('bookings')
                .where(
                  'date',
                  isEqualTo: selectedDate.toString(),
                )
                .where(
                  'serviceId',
                  isEqualTo: widget.serviceId,
                )
                .get();
            List _bookings = data.docs;
            for (DocumentSnapshot booking in _bookings) {
              TimeOfDay bookingTo = TimeOfDay.fromDateTime(
                  DateFormat.Hm().parse(Booking.fromSnapshot(booking).to));
              TimeOfDay bookingFrom = TimeOfDay.fromDateTime(
                  DateFormat.Hm().parse(Booking.fromSnapshot(booking).from));
              double dbookingTo = bookingTo.minute + bookingTo.hour * 60.0;
              double dbookingFrom =
                  bookingFrom.minute + bookingFrom.hour * 60.0;
              if (dtime1 >= dbookingFrom && dtime1 < dbookingTo) {
                setState(() {
                  error = 'This time is already booked';
                  loading1 = false;
                  verified = false;
                });
                return;
              }
              if (dtime2 <= dbookingTo && dtime2 > dbookingFrom) {
                setState(() {
                  error = 'This time is already booked';
                  loading1 = false;
                  verified = false;
                });
                return;
              }
              if (dtime1 <= dbookingFrom && dtime2 >= dbookingTo) {
                setState(() {
                  error = 'This time is already booked';
                  loading1 = false;
                  verified = false;
                });
                return;
              }
            }

            RemoteConfig remoteConfig = RemoteConfig.instance;
            bool updated = await remoteConfig.fetchAndActivate();
            print('HETGJ');
            print(remoteConfig.getDouble('booking_commission'));
            setState(() {
              duration = dtime2 - dtime1;
              servicePrice = duration * double.parse(widget.data['spm']);
              commissionPrice =
                  servicePrice * remoteConfig.getDouble('booking_commission');
              price = servicePrice + commissionPrice;
              loading1 = false;
              verified = true;
            });
          }
        }
      }
    }
  }

  Future<void> _bookButton(time1, time2) async {
    double dtime1 = selectedTime.minute + selectedTime.hour * 60.0;
    double dtime2 = selectedTime2.minute + selectedTime2.hour * 60.0;
    double dNow = DateTime.now().minute + DateTime.now().hour * 60.0;
    var bPlaceData = await FirebaseFirestore.instance
        .collection('locations')
        .doc(widget.placeId)
        .get();
    if (selectedDate.isBefore(DateTime.now())) {
      if (selectedDate.day != DateTime.now().day) {
        setState(() {
          can = false;
        });
        return;
      } else {
        if (dtime1 < dNow) {
          setState(() {
            can = false;
          });
          return;
        }
      }
    }

    if (dtime1 >= dtime2) {
      setState(() {
        can = false;
      });
      return;
    } else {
      if (widget.data['days'][_dow]['status'] == 'closed') {
        setState(() {
          can = false;
        });
        return;
      } else {
        TimeOfDay placeTo = TimeOfDay.fromDateTime(
            DateFormat.Hm().parse(widget.data['days'][_dow]['to']));
        TimeOfDay placeFrom = TimeOfDay.fromDateTime(
            DateFormat.Hm().parse(widget.data['days'][_dow]['from']));
        double dplaceTo = placeTo.minute + placeTo.hour * 60.0;
        double dplaceFrom = placeFrom.minute + placeFrom.hour * 60.0;
        if (dtime1 < dplaceFrom || dtime2 < dplaceFrom) {
          setState(() {
            can = false;
          });
          return;
        }
        if (dtime1 > dplaceTo || dtime2 > dplaceTo) {
          setState(() {
            can = false;
          });
          return;
        }
        if (dtime1 >= dplaceFrom && dtime2 <= dplaceTo) {
          QuerySnapshot data = await FirebaseFirestore.instance
              .collection('bookings')
              .where(
                'date',
                isEqualTo: selectedDate.toString(),
              )
              .where(
                'serviceId',
                isEqualTo: widget.serviceId,
              )
              .get();
          List _bookings = data.docs;
          for (DocumentSnapshot booking in _bookings) {
            TimeOfDay bookingTo = TimeOfDay.fromDateTime(
                DateFormat.Hm().parse(Booking.fromSnapshot(booking).to));
            TimeOfDay bookingFrom = TimeOfDay.fromDateTime(
                DateFormat.Hm().parse(Booking.fromSnapshot(booking).from));
            double dbookingTo = bookingTo.minute + bookingTo.hour * 60.0;
            double dbookingFrom = bookingFrom.minute + bookingFrom.hour * 60.0;
            if (dtime1 >= dbookingFrom && dtime1 < dbookingTo) {
              setState(() {
                can = false;
              });
              return;
            }
            if (dtime2 <= dbookingTo && dtime2 > dbookingFrom) {
              setState(() {
                can = false;
              });
              return;
            }
            if (dtime1 <= dbookingFrom && dtime2 >= dbookingTo) {
              setState(() {
                can = false;
              });
              return;
            }
          }
        }
      }
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat.yMMMd().format(selectedDate);
        _dow = DateFormat.E().format(selectedDate);
      });
      var data1 = await FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('timestamp_date')
          .where(
            'date',
            isEqualTo: selectedDate.toString(),
          )
          .where(
            'serviceId',
            isEqualTo: widget.serviceId,
          )
          .get();
      alreadyBookings = data1.docs;
      if (_dow != null && _time != null && _time2 != null) {
        setState(() {
          loading1 = true;
          verifying = true;
        });
        _verify(
          formatDate(
              DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
              [HH, ':', nn]),
          formatDate(
              DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
              [HH, ':', nn]),
        );
      } else {
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
      }
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        if (int.parse(_minute) < 10) {
          _minute = '0' + _minute;
        }
        _time = _hour + ':' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [HH, ':', nn]).toString();
        if (widget.data['isFixed'] != null && widget.data['isFixed']) {
          int fixedHour = selectedTime.hour;
          int fixedMinute = selectedTime.minute + widget.data['fixedDuration'];
          while (fixedMinute >= 60) {
            fixedHour = fixedHour + 1;
            fixedMinute = fixedMinute - 60;
          }
          if (fixedHour > 23) {
            error = 'Too late';
            loading1 = false;
            verified = false;
            String fixedMinuteString;
            if (fixedMinute < 10) {
              fixedMinuteString = '0' + fixedMinute.toString();
            } else {
              fixedMinuteString = fixedMinute.toString();
            }
            _time2 = fixedHour.toString() + ':' + fixedMinuteString;
          } else {
            String fixedMinuteString;
            if (fixedMinute < 10) {
              fixedMinuteString = '0' + fixedMinute.toString();
            } else {
              fixedMinuteString = fixedMinute.toString();
            }
            _time2 = fixedHour.toString() + ':' + fixedMinuteString;
            selectedTime2 = TimeOfDay(hour: fixedHour, minute: fixedMinute);
          }
        }
      });
      if (_dow != null && _time != null && _time2 != null) {
        setState(() {
          loading1 = true;
          verifying = true;
        });
        _verify(
          formatDate(
              DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
              [HH, ':', nn]),
          formatDate(
              DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
              [HH, ':', nn]),
        );
      } else {
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
      }
    }
  }

  Future<Null> _selectTime2(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime2,
    );
    if (picked != null) {
      setState(() {
        selectedTime2 = picked;
        _hour2 = selectedTime2.hour.toString();
        _minute2 = selectedTime2.minute.toString();
        if (_minute2 == '0') {
          _minute2 = '00';
        } else if (int.parse(_minute2) < 10) {
          _minute2 = '0' + _minute2;
        }
        _time2 = _hour2 + ':' + _minute2;
        _timeController2.text = _time2;
        _timeController2.text = formatDate(
            DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
            [HH, ':', nn]).toString();
      });
      if (_dow != null && _time != null && _time2 != null) {
        setState(() {
          verifying = true;
          loading1 = true;
        });
        _verify(
          formatDate(
              DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
              [HH, ':', nn]),
          formatDate(
              DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
              [HH, ':', nn]),
        );
      } else {
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
      }
    }
  }

  Future<void> prepare() async {
    // try {
    //   final result = await InternetAddress.lookup('https://footyuz.web.app')
    //       .timeout(Duration(minutes: 1));
    //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    //     print('connected');
    //   }
    // } on SocketException catch (_) {
    //   showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: Text(Languages.of(context).serviceScreenNoInternet),
    //         // content: Text(Languages.of(context).profileScreenWantToLeave),
    //         actions: <Widget>[
    //           IconButton(
    //             onPressed: () async {
    //               try {
    //                 final result =
    //                     await InternetAddress.lookup('https://footyuz.web.app');
    //                 if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    //                   Navigator.of(context).pop(true);
    //                 }
    //               } on SocketException catch (_) {}
    //               // prefs.setBool('local_auth', false);
    //               // prefs.setString('local_password', '');
    //             },
    //             icon: Icon(CupertinoIcons.arrow_2_circlepath),
    //             iconSize: 20,
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
    place = await FirebaseFirestore.instance
        .collection('locations')
        .doc(widget.placeId)
        .get();
  }

  Future<void> _checkInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('footyuz.web.app');
      if (response.isNotEmpty) {
        setState(() {
          isConnected = true;
        });
      }
    } on SocketException catch (err) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text(Languages.of(context).serviceScreenNoInternet),
                // content: Text(Languages.of(context).profileScreenWantToLeave),
                actions: <Widget>[
                  IconButton(
                    onPressed: () async {
                      try {
                        final response =
                            await InternetAddress.lookup('footyuz.web.app');
                        if (response.isNotEmpty) {
                          Navigator.of(context).pop(false);
                          setState(() {
                            isConnected = true;
                          });
                        }
                      } on SocketException catch (err) {
                        setState(() {
                          isConnected = false;
                        });
                        print(err);
                      }
                    },
                    icon: Icon(CupertinoIcons.arrow_2_circlepath),
                    iconSize: 20,
                  ),
                ],
              ));
        },
      );
      setState(() {
        isConnected = false;
      });
      print(err);
    }
  }

  @override
  void initState() {
    prepare();
    _checkInternetConnection();

    super.initState();
    // _dateController.text = DateFormat.yMMMd().format(DateTime.now());

    // _timeController.text = formatDate(
    //     DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute), [
    //   HH,
    //   ':',
    //   nn,
    // ]).toString();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return loading
        ? LoadingScreen()
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: darkColor,
              iconTheme: IconThemeData(
                color: primaryColor,
              ),
              title: Text(
                'Booking',
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
                SliverList(
                  delegate: SliverChildListDelegate([
                    SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 25,
                            ),
                            Center(
                              child: Text(
                                widget.data['name'],
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Mon',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Mon']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Mon']['from'] +
                                          ' - ' +
                                          widget.data['days']['Mon']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Mon']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Tue',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Tue']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Tue']['from'] +
                                          ' - ' +
                                          widget.data['days']['Tue']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Tue']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Wed',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Wed']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Wed']['from'] +
                                          ' - ' +
                                          widget.data['days']['Wed']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Wed']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Thu',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Thu']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Thu']['from'] +
                                          ' - ' +
                                          widget.data['days']['Thu']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Thu']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Fri',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Fri']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Fri']['from'] +
                                          ' - ' +
                                          widget.data['days']['Fri']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Fri']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Sat',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Sat']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Sat']['from'] +
                                          ' - ' +
                                          widget.data['days']['Sat']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Sat']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Sun',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Sun']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Sun']['from'] +
                                          ' - ' +
                                          widget.data['days']['Sun']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Sun']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Date',
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _selectDate(context);
                                  },
                                  child: Container(
                                    width: _width * 0.5,
                                    height: _height * 0.1,
                                    margin: EdgeInsets.all(10),
                                    alignment: Alignment.center,
                                    decoration:
                                        BoxDecoration(color: lightPrimaryColor),
                                    child: TextFormField(
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          fontSize: 27,
                                          color: darkPrimaryColor,
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                      enabled: false,
                                      keyboardType: TextInputType.text,
                                      controller: _dateController,
                                      onSaved: (String val) {
                                        _setDate = val;
                                      },
                                      decoration: InputDecoration(
                                          disabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none),
                                          contentPadding:
                                              EdgeInsets.only(top: 0.0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _dow != null
                                ? widget.data['days'][_dow]['status'] ==
                                        'closed'
                                    ? Container()
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(29),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          alignment: Alignment.center,
                                          color: whiteColor,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              alreadyBookings.length != 0
                                                  ? Center(
                                                      child: Text(
                                                        'Already booked',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: darkColor,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              for (var book in alreadyBookings)
                                                Center(
                                                  child: Text(
                                                    Booking.fromSnapshot(book)
                                                            .from
                                                            .toString() +
                                                        ' - ' +
                                                        Booking.fromSnapshot(
                                                                book)
                                                            .to
                                                            .toString(),
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: darkColor,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      )
                                : Container(),
                            Row(
                              children: <Widget>[
                                Text(
                                  'From',
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _selectTime(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    width: _width * 0.3,
                                    height: _height * 0.085,
                                    alignment: Alignment.center,
                                    decoration:
                                        BoxDecoration(color: lightPrimaryColor),
                                    child: TextFormField(
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 20,
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                      onSaved: (String val) {
                                        _setTime = val;
                                      },
                                      enabled: false,
                                      keyboardType: TextInputType.text,
                                      controller: _timeController,
                                      decoration: InputDecoration(
                                          disabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none),
                                          // labelText: 'Time',
                                          contentPadding: EdgeInsets.all(5)),
                                    ),
                                  ),
                                ),
                                Text(
                                  'To',
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                widget.data['isFixed'] != null &&
                                        widget.data['isFixed']
                                    ? _time2 != null
                                        ? Text(
                                            '  ' + _time2,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: darkColor,
                                                fontSize: 20,
                                              ),
                                            ),
                                          )
                                        : Container()
                                    : InkWell(
                                        onTap: () {
                                          _selectTime2(context);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(10),
                                          width: _width * 0.3,
                                          height: _height * 0.085,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: lightPrimaryColor),
                                          child: TextFormField(
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: darkPrimaryColor,
                                                fontSize: 20,
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                            onSaved: (String val) {
                                              _setTime2 = val;
                                            },
                                            enabled: false,
                                            keyboardType: TextInputType.text,
                                            controller: _timeController2,
                                            decoration: InputDecoration(
                                                disabledBorder:
                                                    UnderlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none),
                                                // labelText: 'Time',
                                                contentPadding:
                                                    EdgeInsets.all(5)),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                            SizedBox(height: 10),
                            verifying
                                ? Container(
                                    width: size.width * 0.8,
                                    child: Card(
                                      elevation: 10,
                                      child: loading1
                                          ? Container()
                                          : verified
                                              ? Padding(
                                                  padding: EdgeInsets.all(20),
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          DateFormat.yMMMd()
                                                              .format(
                                                                  selectedDate)
                                                              .toString(),
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: darkColor,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          'From: ' + _time,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: darkColor,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          'To: ' + _time2,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: darkColor,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 15,
                                                        ),
                                                        Text(
                                                          'Service: ' +
                                                              servicePrice
                                                                  .toString() +
                                                              " UZS ",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: darkColor,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                        // SizedBox(
                                                        //   height: 5,
                                                        // ),
                                                        Text(
                                                          'Commission: ' +
                                                              commissionPrice
                                                                  .toString() +
                                                              " UZS ",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: darkColor,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          price.toString() +
                                                              " UZS ",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: darkColor,
                                                              fontSize: 25,
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(height: 30),
                                                        Text(
                                                          'Choose payment method',
                                                          maxLines: 2,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  darkPrimaryColor,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 20),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            widget.data['payment_methods']
                                                                    .contains(
                                                                        'cash')
                                                                ? CupertinoButton(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    onPressed:
                                                                        () {
                                                                      if (payment_way ==
                                                                          'cash') {
                                                                        setState(
                                                                            () {
                                                                          payment_way =
                                                                              '';
                                                                        });
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          payment_way =
                                                                              'cash';
                                                                        });
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: payment_way ==
                                                                                'cash'
                                                                            ? primaryColor
                                                                            : whiteColor,
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: payment_way == 'cash'
                                                                                ? primaryColor.withOpacity(0.5)
                                                                                : darkColor.withOpacity(0.5),
                                                                            spreadRadius:
                                                                                5,
                                                                            blurRadius:
                                                                                7,
                                                                            offset:
                                                                                Offset(0, 3), // changes position of shadow
                                                                          ),
                                                                        ],
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                      ),
                                                                      width: size
                                                                              .width *
                                                                          0.3,
                                                                      height:
                                                                          100,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            CupertinoIcons.money_dollar,
                                                                            size:
                                                                                40,
                                                                            color: payment_way == 'cash'
                                                                                ? whiteColor
                                                                                : darkPrimaryColor,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                            payment_way == 'cash'
                                                                                ? 'Done'
                                                                                : 'Cash',
                                                                            maxLines:
                                                                                3,
                                                                            style:
                                                                                GoogleFonts.montserrat(
                                                                              textStyle: TextStyle(
                                                                                color: payment_way == 'cash' ? whiteColor : darkPrimaryColor,
                                                                                fontSize: 15,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            widget.data['payment_methods']
                                                                    .contains(
                                                                        'octo')
                                                                ? CupertinoButton(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    onPressed:
                                                                        () {
                                                                      if (payment_way ==
                                                                          'octo') {
                                                                        setState(
                                                                            () {
                                                                          payment_way =
                                                                              '';
                                                                        });
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          payment_way =
                                                                              'octo';
                                                                        });
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: payment_way ==
                                                                                'octo'
                                                                            ? primaryColor
                                                                            : whiteColor,
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: payment_way == 'octo'
                                                                                ? primaryColor.withOpacity(0.5)
                                                                                : darkColor.withOpacity(0.5),
                                                                            spreadRadius:
                                                                                5,
                                                                            blurRadius:
                                                                                7,
                                                                            offset:
                                                                                Offset(0, 3), // changes position of shadow
                                                                          ),
                                                                        ],
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                      ),
                                                                      width: size
                                                                              .width *
                                                                          0.3,
                                                                      height:
                                                                          100,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            CupertinoIcons.creditcard,
                                                                            size:
                                                                                40,
                                                                            color: payment_way == 'octo'
                                                                                ? whiteColor
                                                                                : darkPrimaryColor,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                            payment_way == 'octo'
                                                                                ? 'Done'
                                                                                : 'Credit card',
                                                                            maxLines:
                                                                                3,
                                                                            style:
                                                                                GoogleFonts.montserrat(
                                                                              textStyle: TextStyle(
                                                                                color: payment_way == 'octo' ? whiteColor : darkPrimaryColor,
                                                                                fontSize: 15,
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
                                                        SizedBox(
                                                          height: 35,
                                                        ),
                                                        payment_way.isNotEmpty
                                                            ? Center(
                                                                child: Builder(
                                                                  builder:
                                                                      (context) =>
                                                                          RoundedButton(
                                                                    ph: 40,
                                                                    pw: 100,
                                                                    text:
                                                                        'Book',
                                                                    press:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        loading =
                                                                            true;
                                                                      });
                                                                      await _bookButton(
                                                                        formatDate(
                                                                            DateTime(
                                                                                2019,
                                                                                08,
                                                                                1,
                                                                                selectedTime.hour,
                                                                                selectedTime.minute),
                                                                            [
                                                                              HH,
                                                                              ':',
                                                                              nn
                                                                            ]),
                                                                        formatDate(
                                                                            DateTime(
                                                                                2019,
                                                                                08,
                                                                                1,
                                                                                selectedTime2.hour,
                                                                                selectedTime2.minute),
                                                                            [
                                                                              HH,
                                                                              ':',
                                                                              nn
                                                                            ]),
                                                                      );
                                                                      try {
                                                                        final response =
                                                                            await InternetAddress.lookup('footyuz.web.app');
                                                                        if (response
                                                                            .isNotEmpty) {
                                                                          setState(
                                                                              () {
                                                                            isConnected =
                                                                                true;
                                                                          });
                                                                          if (can) {
                                                                            String
                                                                                id =
                                                                                DateTime.now().millisecondsSinceEpoch.toString();
                                                                            FirebaseFirestore.instance.collection('bookings').doc(id).set({
                                                                              'placeId': widget.placeId,
                                                                              'serviceId': widget.serviceId,
                                                                              'userId': FirebaseAuth.instance.currentUser.uid,
                                                                              'price': price.roundToDouble(),
                                                                              'servicePrice': servicePrice.roundToDouble(),
                                                                              'commissionPrice': commissionPrice.roundToDouble(),
                                                                              'from': _time,
                                                                              'to': _time2,
                                                                              'date': selectedDate.toString(),
                                                                              'timestamp_date': selectedDate,
                                                                              'status': widget.data['type'] == 'nonver' ? 'unfinished' : 'verification_needed',
                                                                              'deadline': DateTime(
                                                                                selectedDate.year,
                                                                                selectedDate.month,
                                                                                selectedDate.day,
                                                                                int.parse(_hour) - 1,
                                                                                int.parse(_minute),
                                                                              ),
                                                                              'seen_status': 'unseen',
                                                                              'isRated': false,
                                                                              'payment_method': payment_way,
                                                                            }).catchError((error) {
                                                                              PushNotificationMessage notification = PushNotificationMessage(
                                                                                title: 'Fail',
                                                                                body: 'Failed to make booking',
                                                                              );
                                                                              showSimpleNotification(
                                                                                Container(child: Text(notification.body)),
                                                                                position: NotificationPosition.top,
                                                                                background: Colors.red,
                                                                              );
                                                                              if (this.mounted) {
                                                                                setState(() {
                                                                                  loading = false;
                                                                                });
                                                                              } else {
                                                                                loading = false;
                                                                              }
                                                                            });
                                                                            DocumentSnapshot
                                                                                company =
                                                                                await FirebaseFirestore.instance.collection('companies').doc(place.data()['owner']).get().catchError((error) {
                                                                              PushNotificationMessage notification = PushNotificationMessage(
                                                                                title: 'Fail',
                                                                                body: 'Failed to make booking',
                                                                              );
                                                                              showSimpleNotification(
                                                                                Container(child: Text(notification.body)),
                                                                                position: NotificationPosition.top,
                                                                                background: Colors.red,
                                                                              );
                                                                              if (this.mounted) {
                                                                                setState(() {
                                                                                  loading = false;
                                                                                });
                                                                              } else {
                                                                                loading = false;
                                                                              }
                                                                            });
                                                                            FirebaseFirestore.instance.collection('users').doc(company.data()['owner']).update({
                                                                              'notifications_business': FieldValue.arrayUnion([
                                                                                {
                                                                                  'seen': false,
                                                                                  'type': widget.data['type'] == 'nonver' ? 'new_booking' : 'offered',
                                                                                  'bookingId': id,
                                                                                  'title': widget.data['type'] == 'nonver' ? 'New booking' : 'Offer',
                                                                                  'text': widget.data['type'] == 'nonver' ? 'You have new booking at ' + place.data()['name'] : 'You have new offer at ' + place.data()['name'],
                                                                                  'companyName': company.data()['name'],
                                                                                  'date': DateTime.now(),
                                                                                }
                                                                              ])
                                                                            }).catchError((error) {
                                                                              PushNotificationMessage notification = PushNotificationMessage(
                                                                                title: 'Fail',
                                                                                body: 'Failed to make booking',
                                                                              );
                                                                              showSimpleNotification(
                                                                                Container(child: Text(notification.body)),
                                                                                position: NotificationPosition.top,
                                                                                background: Colors.red,
                                                                              );
                                                                              if (this.mounted) {
                                                                                setState(() {
                                                                                  loading = false;
                                                                                });
                                                                              } else {
                                                                                loading = false;
                                                                              }
                                                                            });

                                                                            setState(() {
                                                                              _dateController.clear();
                                                                              _timeController.clear();
                                                                              _timeController2.clear();
                                                                              selectedDate = DateTime.now();
                                                                              _time = null;
                                                                              _time2 = null;
                                                                              duration = 0;
                                                                              price = 0;
                                                                              servicePrice = 0;
                                                                              commissionPrice = 0;
                                                                              selectedTime = TimeOfDay(hour: 00, minute: 00);
                                                                              selectedTime2 = TimeOfDay(hour: 00, minute: 00);
                                                                              _setDate = null;
                                                                              _dow = null;
                                                                              verified = false;
                                                                              loading1 = false;
                                                                              verifying = false;
                                                                              loading = false;
                                                                              can = true;
                                                                              selectedDate = DateTime.now();
                                                                              payment_way = '';
                                                                            });
                                                                          } else {
                                                                            setState(() {
                                                                              _dateController.clear();
                                                                              _timeController.clear();
                                                                              _timeController2.clear();
                                                                              selectedDate = DateTime.now();
                                                                              _time = null;
                                                                              _time2 = null;
                                                                              duration = 0;
                                                                              price = 0;
                                                                              servicePrice = 0;
                                                                              commissionPrice = 0;
                                                                              selectedTime = TimeOfDay(hour: 00, minute: 00);
                                                                              selectedTime2 = TimeOfDay(hour: 00, minute: 00);
                                                                              _setDate = null;
                                                                              _dow = null;
                                                                              verified = false;
                                                                              loading1 = false;
                                                                              verifying = false;
                                                                              loading = false;
                                                                              can = true;
                                                                              selectedDate = DateTime.now();
                                                                              payment_way = '';
                                                                            });
                                                                          }
                                                                          if (can) {
                                                                            PushNotificationMessage
                                                                                notification =
                                                                                PushNotificationMessage(
                                                                              title: 'Booked',
                                                                              body: 'Bokking was successful',
                                                                            );
                                                                            showSimpleNotification(
                                                                              Container(child: Text(notification.body)),
                                                                              position: NotificationPosition.top,
                                                                              background: darkPrimaryColor,
                                                                            );
                                                                          } else {
                                                                            PushNotificationMessage
                                                                                notification =
                                                                                PushNotificationMessage(
                                                                              title: 'Fail',
                                                                              body: 'Failed to book',
                                                                            );
                                                                            showSimpleNotification(
                                                                              Container(child: Text(notification.body)),
                                                                              position: NotificationPosition.top,
                                                                              background: Colors.red,
                                                                            );
                                                                          }
                                                                        }
                                                                      } on SocketException catch (err) {
                                                                        showDialog(
                                                                          barrierDismissible:
                                                                              false,
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return WillPopScope(
                                                                              onWillPop: () async => false,
                                                                              child: AlertDialog(
                                                                                title: Text(Languages.of(context).serviceScreenNoInternet),
                                                                                // content: Text(Languages.of(context).profileScreenWantToLeave),
                                                                                actions: <Widget>[
                                                                                  IconButton(
                                                                                    onPressed: () async {
                                                                                      try {
                                                                                        final response = await InternetAddress.lookup('footyuz.web.app');
                                                                                        if (response.isNotEmpty) {
                                                                                          Navigator.of(context).pop(false);
                                                                                          setState(() {
                                                                                            isConnected = true;
                                                                                          });
                                                                                        }
                                                                                      } on SocketException catch (err) {
                                                                                        setState(() {
                                                                                          isConnected = false;
                                                                                        });
                                                                                        print(err);
                                                                                      }
                                                                                    },
                                                                                    icon: Icon(CupertinoIcons.arrow_2_circlepath),
                                                                                    iconSize: 20,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                        setState(
                                                                            () {
                                                                          isConnected =
                                                                              false;
                                                                        });
                                                                        print(
                                                                            err);
                                                                      }
                                                                    },
                                                                    color:
                                                                        darkPrimaryColor,
                                                                    textColor:
                                                                        whiteColor,
                                                                  ),
                                                                ),
                                                              )
                                                            : Container()
                                                        // Builder(
                                                        //   builder: (context) =>
                                                        //       RoundedButton(
                                                        //     width: 0.5,
                                                        //     height: 0.07,
                                                        //     text: 'Book',
                                                        //     press: () {
                                                        //       setState(() {
                                                        //         loading = true;
                                                        //       });
                                                        //       FirebaseFirestore
                                                        //           .instance
                                                        //           .collection(
                                                        //               'bookings')
                                                        //           .doc()
                                                        //           .set({
                                                        //         'placeId':
                                                        //             widget.placeId,
                                                        //         'serviceId': widget
                                                        //             .serviceId,
                                                        //         'userId':
                                                        //             FirebaseAuth
                                                        //                 .instance
                                                        //                 .currentUser
                                                        //                 .uid,
                                                        //         'price': price
                                                        //             .roundToDouble(),
                                                        //         'from': _time,
                                                        //         'to': _time2,
                                                        //         'date': selectedDate
                                                        //             .toString(),
                                                        //         'timestamp_date':
                                                        //             selectedDate,
                                                        //         'status': widget.data[
                                                        //                     'type'] ==
                                                        //                 'nonver'
                                                        //             ? 'unfinished'
                                                        //             : 'verification_needed',
                                                        //         'seen_status':
                                                        //             'unseen',
                                                        //         'isRated': false,
                                                        //       });
                                                        //       setState(() {
                                                        //         selectedDate =
                                                        //             DateTime.now();
                                                        //         _time = null;
                                                        //         _time2 = null;
                                                        //         duration = 0;
                                                        //         price = 0;
                                                        //         selectedTime =
                                                        //             TimeOfDay(
                                                        //                 hour: 00,
                                                        //                 minute: 00);
                                                        //         selectedTime2 =
                                                        //             TimeOfDay(
                                                        //                 hour: 00,
                                                        //                 minute: 00);
                                                        //         verified = false;
                                                        //         loading1 = false;
                                                        //         verifying = false;
                                                        //         loading = false;
                                                        //         selectedDate =
                                                        //             DateTime.now();
                                                        //         Scaffold.of(context)
                                                        //             .showSnackBar(
                                                        //           SnackBar(
                                                        //             backgroundColor:
                                                        //                 darkPrimaryColor,
                                                        //             content: Text(
                                                        //               'Booking was successful',
                                                        //               style: GoogleFonts
                                                        //                   .montserrat(
                                                        //                 textStyle:
                                                        //                     TextStyle(
                                                        //                   color:
                                                        //                       whiteColor,
                                                        //                   fontSize:
                                                        //                       30,
                                                        //                 ),
                                                        //               ),
                                                        //             ),
                                                        //           ),
                                                        //         );
                                                        //       });
                                                        //     },
                                                        //     color: darkPrimaryColor,
                                                        //     textColor: whiteColor,
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    error,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 30,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: size.height * 0.2),
                          ],
                        ),
                      ),
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
