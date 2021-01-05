import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_complete_guide/Screens/HomeScreen/home_screen.dart';
import 'package:flutter_complete_guide/Screens/LoginScreen/login_screen.dart';

class AuthService{
  handleAuth(){
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot){
        if(snapshot.hasData){
          return HomeScreen();
        }
        else{
          return LoginScreen();
        }
      }
    );
  }

  signOut(){
    dynamic res = FirebaseAuth.instance.signOut();
    return res;
  }

  signIn(PhoneAuthCredential authCredential){
    try{
      dynamic res = FirebaseAuth.instance.signInWithCredential(authCredential);
      return res;
    }
    catch(e){
      return null;
    }
  }

  signInWithOTP(smsCode, verId){
    try{
      PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
      verificationId: verId,
      smsCode: smsCode,
    );
    dynamic res = signIn(authCredential);
    return res;
    }
    catch(e){
      return null;
    }
  }
}