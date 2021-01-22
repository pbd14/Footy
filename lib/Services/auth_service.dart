import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_complete_guide/Screens/HomeScreen/home_screen.dart';
import 'package:flutter_complete_guide/Screens/LoginScreen/login_screen.dart';
import 'package:flutter_complete_guide/Services/push_notification_service.dart';

class AuthService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  
  handleAuth() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            final pushNotificationService =
                PushNotificationService(_firebaseMessaging);
            pushNotificationService.init();
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        });
  }

  signOut() {
    dynamic res = FirebaseAuth.instance.signOut();
    return res;
  }

  signIn(PhoneAuthCredential authCredential) {
    try {
      dynamic res = FirebaseAuth.instance.signInWithCredential(authCredential);
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .set({'status': 'default'});
      return res;
    } catch (e) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .set({'status': 'not logged in'});
      return null;
    }
  }

  signInWithOTP(smsCode, verId) {
    try {
      PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: smsCode,
      );
      dynamic res = signIn(authCredential);
      return res;
    } catch (e) {
      return null;
    }
  }
}
