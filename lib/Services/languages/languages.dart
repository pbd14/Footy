import 'package:flutter/material.dart';

abstract class Languages {
  
  static Languages of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }

  String get welcomeToFooty;
  String get labelSelectLanguage;
  String get loginScreen1head;
  String get loginScreen1text;
  String get loginScreen2head;
  String get loginScreen2text;
  String get loginScreen3head;
  String get loginScreen3text;
  String get getStarted;
  String get loginScreenYourPhone;
  String get loginScreen6Digits;
  String get loginScreenEnterCode;
  String get loginScreenReenterPhone;
  String get loginScreenPolicy;
  String get loginScreenCodeIsNotValid;


  String get homeScreenBook;
  String get homeScreenFail;
  String get homeScreenFailedToUpdate;
  String get homeScreenSaved;


  String get searchScreenName;


  String get historyScreenSchedule;
  String get historyScreenHistory;
  String get historyScreenUnpaid;
  String get historyScreenInProcess;
  String get historyScreenUpcoming;
  String get historyScreenUnrated;


  String get profileScreenFavs;
  String get profileScreenNotifs;
  String get profileScreenSignOut;
  String get profileScreenWantToLeave;

  String get settingsSettings;
  String get settingsLocalPassword;
  String get settingsLocalPasswordTurnedOff;
  String get settingsLocalPasswordTurnedOn;
  String get settingsDigitPassword;


  String get serviceScreenNoInternet;
}