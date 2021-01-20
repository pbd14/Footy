import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_complete_guide/Screens/PlaceScreen/components/background.dart';
import '../../../constants.dart';

// ignore: must_be_immutable
class PlaceScreen1 extends StatefulWidget {
  Map data;
  PlaceScreen1({Key key, this.data}) : super(key: key);
  @override
  _PlaceScreen1State createState() => _PlaceScreen1State();
}

class _PlaceScreen1State extends State<PlaceScreen1> {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whiteColor,
      body: Background(
        data: widget.data['images'],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(29),
          child: Container(
            color: whiteColor,
            width: size.width * 0.85,
            height: size.height * 0.75,
            margin: EdgeInsets.fromLTRB(size.width * 0.065, size.height * 0,
                size.width * 0.065, size.height * 0),
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
        ),
      ),
    );
  }
}
