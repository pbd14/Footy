import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/LanguageData.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'package:flutter_complete_guide/Services/auth_service.dart';
import 'package:flutter_complete_guide/Services/languages/languages.dart';
import 'package:flutter_complete_guide/Services/languages/locale_constant.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/rounded_button.dart';
import 'package:flutter_complete_guide/widgets/rounded_phone_input_field.dart';
import 'package:flutter_complete_guide/widgets/rounded_text_input.dart';
import 'package:flutter_complete_guide/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  final String errors;
  LoginScreen({Key key, this.errors}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String phoneNo;
  String smsCode;
  String verificationId;
  String error = '';

  bool codeSent = false;
  bool loading = false;

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
            backgroundColor: darkPrimaryColor,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.2,
                  ),
                  Text(
                    Languages.of(context).welcomeToFooty,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        color: whiteColor,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: !codeSent ? 100 : 0,
                  ),
                  !codeSent
                      ? Container(
                          width: size.width * 0.8,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            elevation: 10,
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
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
                                        .map<DropdownMenuItem<LanguageData>>(
                                          (e) => DropdownMenuItem<LanguageData>(
                                            value: e,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                Text(
                                                  e.flag,
                                                  style:
                                                      TextStyle(fontSize: 30),
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
                        )
                      : Container(),
                  SizedBox(
                    height: !codeSent ? 100 : 0,
                  ),
                  !codeSent
                      ? Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              'assets/images/nature1.jpg',
                              height: 200,
                              width: size.width * 0.9,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 120,
                              child: Container(
                                width: size.width * 0.8,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  elevation: 10,
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Languages.of(context)
                                              .loginScreen1head,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: darkColor,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          Languages.of(context)
                                              .loginScreen1text,
                                          maxLines: 10,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: darkColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        )
                      : Container(),
                  SizedBox(
                    height: !codeSent ? 200 : 0,
                  ),
                  !codeSent
                      ? Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              'assets/images/nature2.jpg',
                              height: 200,
                              width: size.width * 0.9,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 120,
                              child: Container(
                                width: size.width * 0.8,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  elevation: 10,
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Languages.of(context)
                                              .loginScreen2head,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: darkColor,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          Languages.of(context)
                                              .loginScreen2text,
                                          maxLines: 10,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: darkColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        )
                      : Container(),
                  SizedBox(
                    height: !codeSent ? 200 : 0,
                  ),
                  !codeSent
                      ? Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              'assets/images/nature3.jpg',
                              height: 200,
                              width: size.width * 0.9,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 120,
                              child: Container(
                                width: size.width * 0.8,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  elevation: 10,
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Languages.of(context)
                                              .loginScreen3head,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: darkColor,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          Languages.of(context)
                                              .loginScreen3text,
                                          maxLines: 10,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: darkColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        )
                      : Container(),
                  SizedBox(
                    height: !codeSent ? 150 : 50,
                  ),
                  Center(
                    child: Container(
                      width: size.width * 0.95,
                      child: Card(
                        margin: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 40,
                              ),
                              Text(
                                Languages.of(context).getStarted,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: darkPrimaryColor,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                              !codeSent
                                  ? Container(
                                      width: size.width * 0.7,
                                      child: RoundedPhoneInputField(
                                        hintText: "Your Phone",
                                        onChanged: (value) {
                                          this.phoneNo = value;
                                        },
                                      ),
                                    )
                                  : SizedBox(height: size.height * 0),
                              codeSent
                                  ? RoundedTextInput(
                                      height: 80,
                                      length: 6,
                                      validator: (val) => val.length == 6
                                          ? null
                                          : 'Code should contain 6 digits',
                                      hintText: "Enter OTP",
                                      type: TextInputType.number,
                                      onChanged: (value) {
                                        this.smsCode = value;
                                      },
                                    )
                                  : SizedBox(height: size.height * 0),
                              codeSent
                                  ? SizedBox(height: 20)
                                  : SizedBox(height: size.height * 0),

                              // RoundedPasswordField(
                              //   hintText: "Password",
                              //   onChanged: (value) {},
                              // ),
                              SizedBox(height: 20),
                              RoundedButton(
                                width: 0.4,
                                ph: 45,
                                text: codeSent ? 'GO' : 'SEND CODE',
                                press: () async {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      loading = true;
                                    });
                                    if (codeSent) {
                                      dynamic res = await AuthService()
                                          .signInWithOTP(
                                              smsCode, verificationId, context);
                                      if (res == null) {
                                        setState(() {
                                          // error = 'Enter valid data';
                                          loading = false;
                                        });
                                      }
                                    } else {
                                      await verifyPhone(phoneNo);
                                    }
                                  }
                                },
                                color: darkPrimaryColor,
                                textColor: whiteColor,
                              ),
                              codeSent
                                  ? SizedBox(height: 55)
                                  : SizedBox(height: size.height * 0),
                              codeSent
                                  ? RoundedButton(
                                      width: 0.6,
                                      ph: 45,
                                      text: 'Re-enter the phone',
                                      press: () {
                                        Navigator.push(
                                            context,
                                            SlideRightRoute(
                                                page: LoginScreen()));
                                      },
                                      color: lightPrimaryColor,
                                      textColor: darkPrimaryColor,
                                    )
                                  : SizedBox(height: size.height * 0),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  error,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                    size.width * 0.05, 0, size.width * 0.05, 0),
                                child: Text(
                                  'Продолжая вы принимаете все правила пользования приложением и нашу Политику Конфиденциальности',
                                  textScaleFactor: 1,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              // RoundedButton(
                              //   text: 'REGISTER',
                              //   press: () {
                              //     Navigator.push(
                              //         context, SlideRightRoute(page: RegisterScreen()));
                              //   },
                              //   color: lightPrimaryColor,
                              //   textColor: darkPrimaryColor,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified =
        (PhoneAuthCredential authResult) {
      AuthService().signIn(authResult, context);
      setState(() {
        loading = false;
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        this.error = '${authException.message}';
        this.loading = false;
      });
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.error = '';
        this.codeSent = true;
        this.loading = false;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = false;
        this.loading = false;
        this.error = 'Code is not valid anymore';
      });
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 100),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }
}
