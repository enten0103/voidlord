import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PicDialogView extends StatelessWidget {
  const PicDialogView({
    super.key,
    required this.image,
  });

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 19,
      child: PhotoView(
        enableRotation: true,
        imageProvider: image,
        backgroundDecoration: BoxDecoration(color: Colors.transparent),
      ),
    );
  }
}
