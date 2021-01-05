// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Screens/footy_screen.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
// import 'package:flutter_complete_guide/Services/auth_service.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'Screens/loading_screen.dart';
// import 'Screens/sww_screen.dart';
import 'constants.dart';
// import 'Screens/LoginScreen/login_screen.dart';

// SHA-1 KEY  19:15:92:FA:6D:EE:79:89:88:63:7A:59:5C:45:75:83:30:26:74:33
// Android API KEY AIzaSyAsZX_bhLde8Aif2ayUgrzisg3yYQxizg8
// IOS API KEY AIzaSyAP76RF198pKogJjyPyEtcB3L_bLfSWgGY
// Bundle ID com.example.flutterCompleteGuide
// Package Name com.example.flutter_complete_guide
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Footy',
        theme: ThemeData(
            primaryColor: primaryColor, scaffoldBackgroundColor: whiteColor),
        home: FootyScreen(),
      
    );

    // return MaterialApp(
    //           debugShowCheckedModeBanner: false,
    //           title: 'Footy',
    //           theme: ThemeData(
    //               primaryColor: primaryColor,
    //               scaffoldBackgroundColor: whiteColor),
    //           home: FootyScreen());
    // return FutureBuilder<Widget>(
    //   // Initialize FlutterFire
    //   future: initApp(),
    //   builder: (context, snapshot) {
    //     // Check for errors
    //     if (snapshot.hasError) {
    //       return SomethingWentWrongScreen();
    //     }
    //     // Once complete, show your application
    //     if (snapshot.hasData) {
    //       return snapshot.data;
    //     } else {
    //       // Otherwise, show something whilst waiting for initialization to complete
    //       return MaterialApp(
    //           debugShowCheckedModeBanner: false,
    //           title: 'Footy',
    //           theme: ThemeData(
    //               primaryColor: primaryColor,
    //               scaffoldBackgroundColor: whiteColor),
    //           home: FootyScreen());
    //     }
    //   },
    // );
  }
}
