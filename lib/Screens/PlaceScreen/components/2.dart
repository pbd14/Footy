import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Booking.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/widgets/card.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

class PlaceScreen2 extends StatefulWidget {
  final Map data;
  PlaceScreen2({Key key, this.data}) : super(key: key);
  @override
  _PlaceScreen2State createState() => _PlaceScreen2State();
}

class _PlaceScreen2State extends State<PlaceScreen2> {
  double _height;
  double _width;
  double duration = 0;
  double price = 0;

  bool verified = false;
  bool loading1 = false;
  bool verifying = false;
  bool loading = false;

  String _setTime, _setTime2, _setDate, error;
  String _hour, _minute, _time, _dow;
  String _hour2, _minute2, _time2;

  String dateTime;

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TimeOfDay selectedTime2 = TimeOfDay(hour: 00, minute: 00);

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _timeController2 = TextEditingController();

  Future<void> _verify(time1, time2) async {
    double dtime1 = selectedTime.minute + selectedTime.hour * 60.0;
    double dtime2 = selectedTime2.minute + selectedTime2.hour * 60.0;
    if (dtime1 >= dtime2 || selectedDate.isBefore(DateTime.now())) {
      setState(() {
        error = 'Incorrect date/time selected';
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
        TimeOfDay place_to = TimeOfDay.fromDateTime(
            DateFormat.Hm().parse(widget.data['days'][_dow]['to']));
        TimeOfDay place_from = TimeOfDay.fromDateTime(
            DateFormat.Hm().parse(widget.data['days'][_dow]['from']));
        double dplace_to = place_to.minute + place_to.hour * 60.0;
        double dplace_from = place_from.minute + place_from.hour * 60.0;
        if (dtime1 < dplace_from || dtime2 < dplace_from) {
          setState(() {
            error = 'Too early';
            loading1 = false;
            verified = false;
          });
          return;
        }
        if (dtime1 > dplace_to || dtime2 > dplace_to) {
          setState(() {
            error = 'Too late';
            loading1 = false;
            verified = false;
          });
          return;
        }
        if (dtime1 >= dplace_from && dtime2 <= dplace_to) {
          var data = await FirebaseFirestore.instance
              .collection('bookings')
              .where(
                'date',
                isEqualTo: selectedDate.toString(),
              )
              .get();
          List _bookings = data.docs;
          for (DocumentSnapshot booking in _bookings) {
            TimeOfDay booking_to = TimeOfDay.fromDateTime(
                DateFormat.Hm().parse(Booking.fromSnapshot(booking).to));
            TimeOfDay booking_from = TimeOfDay.fromDateTime(
                DateFormat.Hm().parse(Booking.fromSnapshot(booking).from));
            double dbooking_to = booking_to.minute + booking_to.hour * 60.0;
            double dbooking_from =
                booking_from.minute + booking_from.hour * 60.0;
            if (dtime1 >= dbooking_from && dtime1 < dbooking_to) {
              setState(() {
                error = 'This time is already booked';
                loading1 = false;
                verified = false;
              });
              return;
            }
            if (dtime2 <= dbooking_to && dtime2 > dbooking_from) {
              setState(() {
                error = 'This time is already booked';
                loading1 = false;
                verified = false;
              });
              return;
            }
          }
          setState(() {
            duration = dtime2 - dtime1;
            price = duration * widget.data['spm'].toDouble();
            loading1 = false;
            verified = true;
          });
        }
      }
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat.yMMMd().format(selectedDate);
        _dow = DateFormat.E().format(selectedDate);
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
        if (_minute == '0') {
          _minute = '00';
        }
        _time = _hour + ':' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [HH, ':', nn]).toString();
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

  @override
  void initState() {
    _dateController.text = DateFormat.yMMMd().format(DateTime.now());

    _timeController.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute), [
      HH,
      ':',
      nn,
    ]).toString();
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
            backgroundColor: whiteColor,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: size.height * 0.04,
                      ),
                      Center(
                        child: Text(
                          widget.data['name'],
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkPrimaryColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Booking',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkPrimaryColor,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.04,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Date',
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: darkPrimaryColor,
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
                                    contentPadding: EdgeInsets.only(top: 0.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _dow != null
                          ? widget.data['days'][_dow]['status'] == 'closed'
                              ? Container()
                              : Center(
                                  child: Text(
                                    'Working from ' +
                                        widget.data['days'][_dow]['from'] +
                                        ' - ' +
                                        widget.data['days'][_dow]['to'],
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: darkPrimaryColor,
                                        fontSize: 20,
                                      ),
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
                                color: darkPrimaryColor,
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
                                color: darkPrimaryColor,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _selectTime2(context);
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
                                  _setTime2 = val;
                                },
                                enabled: false,
                                keyboardType: TextInputType.text,
                                controller: _timeController2,
                                decoration: InputDecoration(
                                    disabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none),
                                    // labelText: 'Time',
                                    contentPadding: EdgeInsets.all(5)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      verifying
                          ? CardW(
                              width: 0.9,
                              height: 0.4,
                              child: loading1
                                  ? LoadingScreen()
                                  : verified
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                DateFormat.yMMMd()
                                                    .format(selectedDate)
                                                    .toString(),
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'From: ' + _time,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'To: ' + _time2,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                price
                                                        .roundToDouble()
                                                        .toString() +
                                                    " So'm ",
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width * 0.1,
                                              ),
                                              RoundedButton(
                                                width: 0.5,
                                                height: 0.07,
                                                text: 'Book',
                                                press: () async {
                                                  setState(() {
                                                    loading = true;
                                                  });
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('bookings')
                                                      .doc()
                                                      .set({
                                                    'placeId':
                                                        widget.data['id'],
                                                    'userId': FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        .uid,
                                                    'price':
                                                        price.roundToDouble(),
                                                    'from': _time,
                                                    'to': _time2,
                                                    'date':
                                                        selectedDate.toString(),
                                                    'timestamp_date' : selectedDate,
                                                    'status' : 
                                                    widget.data['type'] == 'nonver' ? 'unfinished' : 'verification_needed',
                                                  });
                                                  setState(() {
                                                    selectedDate =
                                                        DateTime.now();
                                                    _time = null;
                                                    _time2 = null;
                                                    duration = 0;
                                                    price = 0;
                                                    selectedTime = TimeOfDay(
                                                        hour: 00, minute: 00);
                                                    selectedTime2 = TimeOfDay(
                                                        hour: 00, minute: 00);
                                                    verified = false;
                                                    loading1 = false;
                                                    verifying = false;
                                                    loading = false;
                                                    selectedDate =
                                                        DateTime.now();
                                                    Scaffold.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        backgroundColor:
                                                            darkPrimaryColor,
                                                        content: Text(
                                                          'Booking was successful',
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 30,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                                },
                                                color: darkPrimaryColor,
                                                textColor: whiteColor,
                                              ),
                                            ],
                                          ),
                                        )
                                      : Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            error,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: Colors.red,
                                                fontSize: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                            )
                          : Container(),
                      // Container(
                      //   height: 450,
                      //   width: size.width,
                      //   child: SfCalendar(
                      //     allowViewNavigation: true,
                      //     view: CalendarView.month,
                      //     firstDayOfWeek: 1,
                      //     monthViewSettings: MonthViewSettings(
                      //       showAgenda: true,
                      //       agendaStyle: AgendaStyle(
                      //         dateTextStyle: GoogleFonts.montserrat(
                      //           textStyle: TextStyle(
                      //             color: darkPrimaryColor,
                      //           ),
                      //         ),
                      //         dayTextStyle: GoogleFonts.montserrat(
                      //           textStyle: TextStyle(
                      //             color: darkPrimaryColor,
                      //           ),
                      //         ),
                      //         appointmentTextStyle: GoogleFonts.montserrat(
                      //           textStyle: TextStyle(
                      //             color: darkPrimaryColor,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}