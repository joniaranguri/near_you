import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../model/slide.dart';


class SlideItem extends StatelessWidget {
  final int index;
  SlideItem(this.index);

  @override
  Widget build(BuildContext context) {
    return
      Padding(
          // Different Padding For All Sides
          padding: EdgeInsets.fromLTRB(0, 100, 0, 20),

          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: double.maxFinite,
                height: 255,
                child: SvgPicture.asset(slideList[index].imageUrl)
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              slideList[index].title,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xffd333333),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 60, left: 60),
              child:Text(
                slideList[index].description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffd555555),
                ),
              ),
            )
          ],
    ));
  }
}
