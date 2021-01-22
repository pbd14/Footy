import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/Booking.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/widgets/card.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class PlaceScreen extends StatefulWidget {
  Map data;
  PlaceScreen({Key key, this.data}) : super(key: key);
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  bool loading = false;
  double _height;
  double _width;
  double duration = 0;
  double price = 0;

  bool verified = false;
  bool loading1 = false;
  bool verifying = false;

  // ignore: unused_field
  String _setTime, _setTime2, _setDate, error;
  String _hour, _minute, _time, _dow;
  String _hour2, _minute2, _time2;
  String dateTime;

  List imgList = [];

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TimeOfDay selectedTime2 = TimeOfDay(hour: 00, minute: 00);

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _timeController2 = TextEditingController();

  Future<void> _verify(time1, time2) async {
    double dtime1 = selectedTime.minute + selectedTime.hour * 60.0;
    double dtime2 = selectedTime2.minute + selectedTime2.hour * 60.0;
    double dNow = DateTime.now().minute + DateTime.now().hour * 60.0;
    if (selectedDate.isBefore(DateTime.now())) {
      if (selectedDate.day != DateTime.now().day) {
        print('LOOK WE HAVE DATE HERE');
        print(selectedDate.toString());
        print(DateTime.now().toString());
        setState(() {
          error = 'Incorrect date selected';
          loading1 = false;
          verified = false;
        });
        return;
      }
    }
    if (dtime1 < dNow) {
      setState(() {
        error = 'Incorrect date selected';
        loading1 = false;
        verified = false;
      });
      return;
    }
    if (dtime1 >= dtime2) {
      setState(() {
        error = 'Incorrect time selected';
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
          }
          setState(() {
            print('LOOK WE HAVE A TYPE HERE');
            print(widget.data['type']);
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
        if (int.parse(_minute) < 10) {
          _minute = '0' + _minute;
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
        if (int.parse(_minute2) < 10) {
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

  final controller = PageController(
    initialPage: 1,
  );

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
    for (String img in widget.data['images']) {
      imgList.add(img);
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
                  backgroundColor: darkPrimaryColor,
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
                  delegate: SliverChildListDelegate(
                    [
                    Container(
                      color: whiteColor,
                      width: size.width * 0.85,
                      height: size.height * 0.75,
                      margin: EdgeInsets.fromLTRB(size.width * 0.065,
                          size.height * 0, size.width * 0.065, size.height * 0),
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
                                    height: size.height * 0.02,
                                  ),
                                  Text(
                                    widget.data['description'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: darkPrimaryColor,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.02,
                                  ),
                                  Text(
                                    'By ' + widget.data['by'],
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: darkPrimaryColor,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
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
                                    : Center(
                                        child: Text(
                                          'Working from ' +
                                              widget.data['days'][_dow]
                                                  ['from'] +
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
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color:
                                                              darkPrimaryColor,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'From: ' + _time,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color:
                                                              darkPrimaryColor,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'To: ' + _time2,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color:
                                                              darkPrimaryColor,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      price
                                                              .roundToDouble()
                                                              .toString() +
                                                          " So'm ",
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color:
                                                              darkPrimaryColor,
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
                                                            .collection(
                                                                'bookings')
                                                            .doc()
                                                            .set({
                                                          'placeId':
                                                              widget.data['id'],
                                                          'userId': FirebaseAuth
                                                              .instance
                                                              .currentUser
                                                              .uid,
                                                          'price': price
                                                              .roundToDouble(),
                                                          'from': _time,
                                                          'to': _time2,
                                                          'date': selectedDate
                                                              .toString(),
                                                          'timestamp_date':
                                                              selectedDate,
                                                          'status': widget.data[
                                                                      'type'] ==
                                                                  'nonver'
                                                              ? 'unfinished'
                                                              : 'verification_needed',
                                                        });
                                                        setState(() {
                                                          selectedDate =
                                                              DateTime.now();
                                                          _time = null;
                                                          _time2 = null;
                                                          duration = 0;
                                                          price = 0;
                                                          selectedTime =
                                                              TimeOfDay(
                                                                  hour: 00,
                                                                  minute: 00);
                                                          selectedTime2 =
                                                              TimeOfDay(
                                                                  hour: 00,
                                                                  minute: 00);
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
                                                                    color:
                                                                        whiteColor,
                                                                    fontSize:
                                                                        30,
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
                                SizedBox(
                                  height: size.height * 0.2
                                ),
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
