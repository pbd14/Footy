// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_complete_guide/Services/local_notification.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Services/auth_service.dart';
import 'package:overlay_support/overlay_support.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:workmanager/workmanager.dart';
// import 'Models/Booking.dart';
import 'constants.dart';
// import 'package:timezone/timezone.dart' as tz;

// SHA-1 KEY  19:15:92:FA:6D:EE:79:89:88:63:7A:59:5C:45:75:83:30:26:74:33
// Android API KEY AIzaSyAsZX_bhLde8Aif2ayUgrzisg3yYQxizg8
// IOS API KEY AIzaSyAP76RF198pKogJjyPyEtcB3L_bLfSWgGY
// Bundle ID com.example.flutterCompleteGuide
// Package Name com.example.flutter_complete_guide

// const checkBookings = "Check bookings";
// List _bookings;

// void callbackDispatcher() {
//   Workmanager.executeTask((task, inputData) async {
//     switch (task) {
//       case checkBookings:
//         print("$checkBookings was executed. inputData = $inputData");
//         final prefs = await SharedPreferences.getInstance();
//         prefs.setBool("test", true);
//         print("Bool from prefs: ${prefs.getBool("test")}");
//         LocalNotification.Initializer();
//         LocalNotification.ShowOneTimeNotification(
//             tz.TZDateTime.now(tz.getLocation('Uzbekistan/Tashkent')));
// var data = await FirebaseFirestore.instance
//     .collection('bookings')
//     .orderBy(
//       'timestamp_date',
//       descending: true,
//     )
//     .where(
//       'status',
//       whereIn: ['unfinished', 'verification_needed'],
//     )
//     .where(
//       'userId',
//       isEqualTo: FirebaseAuth.instance.currentUser.uid,
//     )
//     .get();
// _bookings = data.docs;
// for (dynamic book in _bookings) {
//   TimeOfDay booking_to = TimeOfDay.fromDateTime(
//       DateFormat.Hm().parse(Booking.fromSnapshot(book).to));
//   TimeOfDay booking_from = TimeOfDay.fromDateTime(
//       DateFormat.Hm().parse(Booking.fromSnapshot(book).from));
//   double dbooking_to = booking_to.minute + booking_to.hour * 60.0;
//   double dbooking_from = booking_from.minute + booking_from.hour * 60.0;
//   double dnow = DateTime.now().minute + DateTime.now().hour * 60.0;
//   if (dnow == dbooking_from) {
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser.uid)
//         .set({'status': 'on booking'});
//     FirebaseFirestore.instance
//         .collection('bookings')
//         .doc(book.id)
//         .set({'status': 'in process'});
//   }
//   if (dnow > dbooking_from && dnow < dbooking_to) {
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser.uid)
//         .set({'status': 'on booking'});
//     FirebaseFirestore.instance
//         .collection('bookings')
//         .doc(book.id)
//         .set({'status': 'in process'});
//   }
//   if (dnow >= dbooking_to) {
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser.uid)
//         .set({'status': 'default'});
//     FirebaseFirestore.instance
//         .collection('bookings')
//         .doc(book.id)
//         .set({'status': 'finished'});
//   }
// }
//         break;
//       case Workmanager.iOSBackgroundTask:
//         print("The iOS background fetch was triggered");
//         Directory tempDir = await getTemporaryDirectory();
//         String tempPath = tempDir.path;
//         print(
//             "You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath");
//         break;
//     }

//     return Future.value(true);
//   });
// }

void main() async{
  // WidgetsFlutterBinding.ensureInitialized();
  // Workmanager.initialize(
  //     callbackDispatcher, // The top level function, aka callbackDispatcher
  //     isInDebugMode:
  //         true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  //     );
  // Workmanager.registerPeriodicTask("1", checkBookings,
  //     frequency: Duration(minutes: 5),
  //     initialDelay: Duration(minutes: 1),
  //     constraints: Constraints(
  //       networkType: NetworkType.connected,
  //     ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Footy',
        theme: ThemeData(
            primaryColor: primaryColor, scaffoldBackgroundColor: whiteColor),
        home: AuthService().handleAuth(),
        // new SplashScreen(
        //   navigateAfterFuture: prepare(),
        //   image: new Image.asset(
        //     'assets/images/Footy.png',
        //   ),
        //   backgroundColor: Colors.white,
        //   photoSize: 150.0,
        //   loaderColor: primaryColor,
        // ),
      ),
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
