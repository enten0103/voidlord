import 'package:flutter/material.dart';

class VerticalClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.height, double.infinity);
  }

  @override
  bool shouldReclip(VerticalClipper oldClipper) => false;
}
