import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/constants.dart';

class Background extends StatefulWidget {
  final Widget child;
  final List data;
  const Background({Key key, @required this.child, @required this.data})
      : super(key: key);

  @override
  _BackgroundState createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  List imgList = [];

  @override
  void initState() {
    super.initState();
    for (String img in widget.data) {
      imgList.add(img);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Container(
            color: whiteColor,
            child: CarouselSlider(
              options: CarouselOptions(),
              items: imgList
                  .map((item) => Container(
                        child: Center(
                            child: Align(
                          alignment: Alignment.topCenter,
                          child: Image.network(
                            item,
                            fit: BoxFit.cover,
                            width: size.width,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: whiteColor,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              );
                            },
                          ),
                        )),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
      color: primaryColor,
    );
  }
}
