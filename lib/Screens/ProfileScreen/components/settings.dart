import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_complete_guide/Models/LanguageData.dart';
import 'package:flutter_complete_guide/Models/PushNotificationMessage.dart';
import 'package:flutter_complete_guide/Services/languages/languages.dart';
import 'package:flutter_complete_guide/Services/languages/locale_constant.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/rounded_text_input.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../loading_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String errors;
  SettingsScreen({Key key, this.errors}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  SharedPreferences prefs;
  var value1;
  bool expV1 = false;
  String error = '';
  String lang;
  bool loading = true;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> prepare() async {
    prefs = await SharedPreferences.getInstance();
    value1 = prefs.getBool('local_auth') ?? false;
    lang = prefs.getString('lang') ?? '';
    if (value1) {
      // Navigator.push(
      //   context,
      //   SlideRightRoute(
      //     page: ScreenLock(
      //       correctString: prefs.getString('local_password'),
      //       canCancel: false,
      //     ),
      //   ),
      // );
      screenLock(
          context: context,
          correctString: prefs.getString('local_password'),
          canCancel: false);
    }
    if (this.mounted) {
      setState(() {
        expV1 = value1;
        loading = false;
      });
    } else {
      expV1 = value1;
      loading = false;
    }
  }

  void initState() {
    prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (widget.errors != null) {
      setState(() {
        error = widget.errors;
      });
    }
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: whiteColor),
              toolbarHeight: size.width * 0.17,
              backgroundColor: darkColor,
              centerTitle: true,
              title: Text(
                Languages.of(context).settingsSettings,
                overflow: TextOverflow.ellipsis,
                textScaleFactor: 1,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    color: whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            backgroundColor: primaryColor,
            body: Container(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.5 - 225,
                      ),
                      Container(
                        width: 0.9 * size.width,
                        child: Column(
                          children: [
                            Card(
                              elevation: 10,
                              margin: EdgeInsets.all(5),
                              shadowColor: whiteColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  key: _formKey1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Center(
                                          child: Text(
                                            Languages.of(context).settingsSettings,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: darkColor,
                                                fontSize: 27,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Language',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkColor,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      DropdownButton<LanguageData>(
                                        iconSize: 30,
                                        hint: Text(Languages.of(context)
                                            .labelSelectLanguage),
                                        onChanged: (LanguageData language) {
                                          changeLanguage(
                                              context, language.languageCode);
                                        },
                                        items: LanguageData.languageList()
                                            .map<
                                                DropdownMenuItem<LanguageData>>(
                                              (e) => DropdownMenuItem<
                                                  LanguageData>(
                                                value: e,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Text(
                                                      e.flag,
                                                      style: TextStyle(
                                                          fontSize: 30),
                                                    ),
                                                    Text(e.name)
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              elevation: 10,
                              margin: EdgeInsets.all(5),
                              shadowColor: whiteColor,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 7,
                                          child: Text(
                                            Languages.of(context).settingsLocalPassword,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: darkColor,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Switch(
                                            activeColor: primaryColor,
                                            value: expV1,
                                            onChanged: (val) {
                                              if (this.mounted) {
                                                setState(() {
                                                  expV1 = val;
                                                  if (!val) {
                                                    prefs.setBool(
                                                        'local_auth', expV1);
                                                    prefs.setString(
                                                        'local_password', '');
                                                    PushNotificationMessage
                                                        notification =
                                                        PushNotificationMessage(
                                                      title: Languages.of(context).homeScreenSaved,
                                                      body:
                                                          Languages.of(context).settingsLocalPasswordTurnedOff,
                                                    );
                                                    showSimpleNotification(
                                                      Container(
                                                        child: Text(
                                                            notification.body),
                                                      ),
                                                      position:
                                                          NotificationPosition
                                                              .top,
                                                      background: Colors.red,
                                                    );
                                                  }
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    ExpansionPanelList(
                                      elevation: 0,
                                      children: [
                                        ExpansionPanel(
                                          isExpanded: expV1,
                                          headerBuilder: (context, isOpen) {
                                            return Center(
                                              child: Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      5, 2, 5, 2),
                                                  child:
                                                      Text('4-значный пароль')),
                                            );
                                          },
                                          body: Center(
                                            child: RoundedTextInput(
                                              height: 80,
                                              length: 4,
                                              initialValue: prefs.getString(
                                                          'local_password') !=
                                                      null
                                                  ? '****'
                                                  : '',
                                              validator: (val) {
                                                if (val.length != 4) {
                                                  return "Нужен 4-значный код";
                                                }
                                              },
                                              formatters: [
                                                FilteringTextInputFormatter
                                                    .allow(
                                                        RegExp(r"[0-9]+|\s")),
                                              ],
                                              hintText: 'Password',
                                              type: TextInputType.number,
                                              onChanged: (value) {
                                                if (value.length == 4) {
                                                  prefs.setBool(
                                                      'local_auth', expV1);
                                                  prefs.setString(
                                                      'local_password', value);
                                                  PushNotificationMessage
                                                      notification =
                                                      PushNotificationMessage(
                                                    title: Languages.of(context).homeScreenSaved,
                                                    body:
                                                        Languages.of(context).settingsLocalPasswordTurnedOn,
                                                  );
                                                  showSimpleNotification(
                                                    Container(
                                                        child: Text(
                                                            notification.body)),
                                                    position:
                                                        NotificationPosition
                                                            .top,
                                                    background: primaryColor,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
