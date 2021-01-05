import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Screens/PlaceScreen/components/1.dart';
import 'package:flutter_complete_guide/Screens/loading_screen.dart';
import 'components/2.dart';

class PlaceScreen extends StatefulWidget {
  Map data;
  PlaceScreen({Key key, this.data}) : super(key: key);
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  final controller = PageController(
    initialPage: 1,
  );

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : PageView(
          controller: controller,
          scrollDirection: Axis.vertical,
          children: [
            PlaceScreen1(
              data: widget.data,
            ),
            PlaceScreen2(
              data: widget.data,
            ),
          ],
        );
  }
}
