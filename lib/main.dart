import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Services/auth_service.dart';
import 'package:flutter_complete_guide/Services/languages/applocalizationsdelegate.dart';
import 'package:flutter_complete_guide/Services/languages/locale_constant.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'constants.dart';

// SHA-1 KEY  19:15:92:FA:6D:EE:79:89:88:63:7A:59:5C:45:75:83:30:26:74:33
// SHA-256 33:88:c5:61:62:cc:38:a9:cc:fe:3a:37:0a:17:70:2c:4f:86:bf:47:4b:6a:75:df:3c:88:ad:0d:8d:07:e5:5a
// Google Play SHA-1 A9:15:AB:AC:F8:B9:CA:48:3F:5D:3E:DC:D8:5B:B0:DA:9C:32:A0:EB
// Google Play SHA-256 A3:F6:72:A8:A7:2E:4E:11:A9:CC:13:C3:4E:19:25:00:2C:F6:37:1B:74:70:BF:E1:3A:31:C2:4C:34:0B:69:BC
// Android API KEY AIzaSyAsZX_bhLde8Aif2ayUgrzisg3yYQxizg8
// IOS API KEY AIzaSyAP76RF198pKogJjyPyEtcB3L_bLfSWgGY
// Bundle ID com.example.flutterCompleteGuide
// Package Name com.footy.uz
// OCTO Secret key c66db06a-6bd7-4029-bb8c-1f582d33b62a

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Footy',
        locale: _locale,
        theme: ThemeData(
            primaryColor: primaryColor, scaffoldBackgroundColor: whiteColor),
        home: AuthService().handleAuth(),
        supportedLocales: [
          Locale('en', ''),
          Locale('ru', ''),
          Locale('uz', ''),
        ],
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale?.languageCode == locale?.languageCode &&
                supportedLocale?.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales?.first;
        },
      ),
    );
  }
}
