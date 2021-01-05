import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Services/auth_service.dart';
import 'package:flutter_complete_guide/constants.dart';

class FootyScreen extends StatefulWidget {
  @override
  _FootyScreenState createState() => _FootyScreenState();
}

// class _FootyScreenState extends State<FootyScreen> {
//   Future<Widget> loadFromFuture() async {
//     await Firebase.initializeApp();
//     return Future.value(AuthService().handleAuth());
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return SplashScreen(
//       navigateAfterFuture: loadFromFuture(),
//       image: Image.asset(
//         'assets/images/Footy.png',
//         width: 1 * size.width,
//       ),
//       photoSize: 100.0,
//       backgroundColor: Colors.white,
//       useLoader: false,
//     );
//   }
// }

class _FootyScreenState extends State<FootyScreen> {
  void initState() {
    Timer(Duration(seconds: 2), () async {
      await Firebase.initializeApp();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => AuthService().handleAuth()));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 100),
        color: whiteColor,
        child: Center(
          child: Image.asset(
            'assets/images/Footy.png',
            width: 1 * size.width,
          ),
        ),
      ),
    );
  }
}
