import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

enum BackgroundSizeMode {
  contain,
  cover,
  auto,
  percentage,
  fixed,
}

class BackgroundSize {
  final BackgroundSizeMode widthMode;
  final BackgroundSizeMode heightMode;
  final double widthValue;
  final double heightValue;

  const BackgroundSize({
    this.widthMode = BackgroundSizeMode.auto,
    this.heightMode = BackgroundSizeMode.auto,
    this.widthValue = 0,
    this.heightValue = 0,
  });

  const BackgroundSize.fixed(double width, double height)
      : this(
          widthMode: BackgroundSizeMode.fixed,
          heightMode: BackgroundSizeMode.fixed,
          widthValue: width,
          heightValue: height,
        );

  const BackgroundSize.percentage(double width, double height)
      : this(
          widthMode: BackgroundSizeMode.percentage,
          heightMode: BackgroundSizeMode.percentage,
          widthValue: width,
          heightValue: height,
        );
}

class _DecorationImagePainter implements DecorationImagePainter {
  _DecorationImagePainter._(this._details, this._onChanged) {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'package:voidlord/reader.dart',
        className: '$_DecorationImagePainter',
        object: this,
      );
    }
  }

  final TonoDecorationImage _details;
  final VoidCallback _onChanged;

  ImageStream? _imageStream;
  ImageInfo? _image;

  @override
  void paint(
    Canvas canvas,
    Rect rect,
    Path? clipPath,
    ImageConfiguration configuration, {
    double blend = 1.0,
    BlendMode blendMode = BlendMode.srcOver,
  }) {
    final ImageStream newImageStream = _details.image.resolve(configuration);
    if (newImageStream.key != _imageStream?.key) {
      final ImageStreamListener listener = ImageStreamListener(
        _handleImage,
        onError: _details.onError,
      );
      _imageStream?.removeListener(listener);
      _imageStream = newImageStream;
      _imageStream!.addListener(listener);
    }
    if (_image == null) {
      return;
    }

    if (clipPath != null) {
      canvas.save();
      canvas.clipPath(clipPath);
    }
    final Size imageSize = Size(
      _image!.image.width.toDouble(),
      _image!.image.height.toDouble(),
    );
    final Size targetSize = _calculateTargetSize(
      configuration.size!,
      imageSize,
      _details.size,
    );
    final Rect destinationRect = (_details.alignment as Alignment).inscribe(
      targetSize,
      rect,
    );
    paintImage(
      canvas: canvas,
      rect: destinationRect,
      image: _image!.image,
      scale: _details.scale,
      fit: BoxFit.fill,
      repeat: _details.repeat,
      alignment: _details.alignment as Alignment,
      centerSlice: _details.centerSlice,
    );

    if (clipPath != null) {
      canvas.restore();
    }
  }

  Size _calculateTargetSize(
    Size containerSize,
    Size imageSize,
    BackgroundSize sizeConfig,
  ) {
    double width = containerSize.width;
    double height = containerSize.height;

    switch (sizeConfig.widthMode) {
      case BackgroundSizeMode.contain:
      case BackgroundSizeMode.cover:
        final aspectRatio = imageSize.width / imageSize.height;
        width = height * aspectRatio;
        break;
      case BackgroundSizeMode.percentage:
        width = containerSize.width * sizeConfig.widthValue;
        break;
      case BackgroundSizeMode.fixed:
        width = sizeConfig.widthValue;
        break;
      case BackgroundSizeMode.auto:
        width = min(containerSize.width, imageSize.width);
        break;
    }
    switch (sizeConfig.heightMode) {
      case BackgroundSizeMode.contain:
      case BackgroundSizeMode.cover:
        final aspectRatio = imageSize.height / imageSize.width;
        height = width * aspectRatio;
        break;
      case BackgroundSizeMode.percentage:
        height = containerSize.height * sizeConfig.heightValue;
        break;
      case BackgroundSizeMode.fixed:
        height = sizeConfig.heightValue;
        break;
      case BackgroundSizeMode.auto:
        height = min(containerSize.height, imageSize.height);
        break;
    }

    if (sizeConfig.widthMode == BackgroundSizeMode.contain ||
        sizeConfig.heightMode == BackgroundSizeMode.contain) {
      return _applyContain(containerSize, Size(width, height));
    }

    if (sizeConfig.widthMode == BackgroundSizeMode.cover ||
        sizeConfig.heightMode == BackgroundSizeMode.cover) {
      return _applyCover(containerSize, Size(width, height));
    }

    return Size(width, height);
  }

  double max(double a, double b) {
    return a > b ? a : b;
  }

  double min(double a, double b) {
    return a > b ? b : a;
  }

  Size _applyContain(Size container, Size size) {
    final double scale = min(
      container.width / size.width,
      container.height / size.height,
    );
    return Size(size.width * scale, size.height * scale);
  }

  Size _applyCover(Size container, Size size) {
    final double scale = max(
      container.width / size.width,
      container.height / size.height,
    );

    return Size(size.width * scale, size.height * scale);
  }

  void _handleImage(ImageInfo value, bool synchronousCall) {
    if (_image == value) {
      return;
    }
    if (_image != null && _image!.isCloneOf(value)) {
      value.dispose();
      return;
    }
    _image?.dispose();
    _image = value;
    if (!synchronousCall) {
      _onChanged();
    }
  }

  @override
  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    _imageStream?.removeListener(
        ImageStreamListener(_handleImage, onError: _details.onError));
    _image?.dispose();
    _image = null;
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'DecorationImagePainter')}(stream: $_imageStream, image: $_image) for $_details';
  }
}

class TonoDecorationImage extends DecorationImage {
  final BackgroundSize size;
  const TonoDecorationImage({
    required super.image,
    super.centerSlice,
    this.size = const BackgroundSize(),
    super.alignment = Alignment.center,
    super.repeat = ImageRepeat.noRepeat,
    super.matchTextDirection = false,
    super.scale = 1.0,
  });
}

class TonoBoxDecoration extends Decoration {
  final TonoDecorationImage? image;
  final Color? color;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final BlendMode? backgroundBlendMode;
  final BoxShape shape;

  const TonoBoxDecoration({
    this.image,
    this.color,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.backgroundBlendMode,
    this.shape = BoxShape.rectangle,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _TonoBoxDecorationPainter(this, onChanged);
  }

  @override
  TonoBoxDecoration lerpFrom(Decoration? a, double t) {
    return super.lerpFrom(a, t) as TonoBoxDecoration;
  }

  @override
  TonoBoxDecoration lerpTo(Decoration? b, double t) {
    return super.lerpTo(b, t) as TonoBoxDecoration;
  }
}

class _TonoBoxDecorationPainter extends BoxPainter {
  _TonoBoxDecorationPainter(this._decoration, super.onChanged);

  final TonoBoxDecoration _decoration;

  Paint? _cachedBackgroundPaint;
  Rect? _rectForCachedBackgroundPaint;
  Paint _getBackgroundPaint(Rect rect, TextDirection? textDirection) {
    assert(
        _decoration.gradient != null || _rectForCachedBackgroundPaint == null);

    if (_cachedBackgroundPaint == null ||
        (_decoration.gradient != null &&
            _rectForCachedBackgroundPaint != rect)) {
      final Paint paint = Paint();
      if (_decoration.backgroundBlendMode != null) {
        paint.blendMode = _decoration.backgroundBlendMode!;
      }
      if (_decoration.color != null) {
        paint.color = _decoration.color!;
      }
      if (_decoration.gradient != null) {
        paint.shader = _decoration.gradient!
            .createShader(rect, textDirection: textDirection);
        _rectForCachedBackgroundPaint = rect;
      }
      _cachedBackgroundPaint = paint;
    }

    return _cachedBackgroundPaint!;
  }

  void _paintBox(
      Canvas canvas, Rect rect, Paint paint, TextDirection? textDirection) {
    switch (_decoration.shape) {
      case BoxShape.circle:
        assert(_decoration.borderRadius == null);
        final Offset center = rect.center;
        final double radius = rect.shortestSide / 2.0;
        canvas.drawCircle(center, radius, paint);
      case BoxShape.rectangle:
        if (_decoration.borderRadius == null ||
            _decoration.borderRadius == BorderRadius.zero) {
          canvas.drawRect(rect, paint);
        } else {
          canvas.drawRRect(
              _decoration.borderRadius!.resolve(textDirection).toRRect(rect),
              paint);
        }
    }
  }

  void _paintShadows(Canvas canvas, Rect rect, TextDirection? textDirection) {
    if (_decoration.boxShadow == null) {
      return;
    }
    for (final BoxShadow boxShadow in _decoration.boxShadow!) {
      final Paint paint = boxShadow.toPaint();
      final Rect bounds =
          rect.shift(boxShadow.offset).inflate(boxShadow.spreadRadius);
      assert(() {
        if (debugDisableShadows && boxShadow.blurStyle == BlurStyle.outer) {
          canvas.save();
          canvas.clipRect(bounds);
        }
        return true;
      }());
      _paintBox(canvas, bounds, paint, textDirection);
      assert(() {
        if (debugDisableShadows && boxShadow.blurStyle == BlurStyle.outer) {
          canvas.restore();
        }
        return true;
      }());
    }
  }

  void _paintBackgroundColor(
      Canvas canvas, Rect rect, TextDirection? textDirection) {
    if (_decoration.color != null || _decoration.gradient != null) {
      // When border is filled, the rect is reduced to avoid anti-aliasing
      // rounding error leaking the background color around the clipped shape.
      final Rect adjustedRect =
          _adjustedRectOnOutlinedBorder(rect, textDirection);
      _paintBox(canvas, adjustedRect, _getBackgroundPaint(rect, textDirection),
          textDirection);
    }
  }

  double _calculateAdjustedSide(BorderSide side) {
    if (side.color.a == 255 && side.style == BorderStyle.solid) {
      return side.strokeInset;
    }
    return 0;
  }

  Rect _adjustedRectOnOutlinedBorder(Rect rect, TextDirection? textDirection) {
    if (_decoration.border == null) {
      return rect;
    }

    if (_decoration.border is Border) {
      final Border border = _decoration.border! as Border;

      final EdgeInsets insets = EdgeInsets.fromLTRB(
            _calculateAdjustedSide(border.left),
            _calculateAdjustedSide(border.top),
            _calculateAdjustedSide(border.right),
            _calculateAdjustedSide(border.bottom),
          ) /
          2;

      return Rect.fromLTRB(
        rect.left + insets.left,
        rect.top + insets.top,
        rect.right - insets.right,
        rect.bottom - insets.bottom,
      );
    } else if (_decoration.border is BorderDirectional &&
        textDirection != null) {
      final BorderDirectional border = _decoration.border! as BorderDirectional;
      final BorderSide leftSide =
          textDirection == TextDirection.rtl ? border.end : border.start;
      final BorderSide rightSide =
          textDirection == TextDirection.rtl ? border.start : border.end;

      final EdgeInsets insets = EdgeInsets.fromLTRB(
            _calculateAdjustedSide(leftSide),
            _calculateAdjustedSide(border.top),
            _calculateAdjustedSide(rightSide),
            _calculateAdjustedSide(border.bottom),
          ) /
          2;

      return Rect.fromLTRB(
        rect.left + insets.left,
        rect.top + insets.top,
        rect.right - insets.right,
        rect.bottom - insets.bottom,
      );
    }
    return rect;
  }

  DecorationImagePainter? _imagePainter;
  void _paintBackgroundImage(
      Canvas canvas, Rect rect, ImageConfiguration configuration) {
    if (_decoration.image == null) {
      return;
    }
    _imagePainter ??= _DecorationImagePainter._(_decoration.image!, onChanged!);
    Path? clipPath;
    switch (_decoration.shape) {
      case BoxShape.circle:
        assert(_decoration.borderRadius == null);
        final Offset center = rect.center;
        final double radius = rect.shortestSide / 2.0;
        final Rect square = Rect.fromCircle(center: center, radius: radius);
        clipPath = Path()..addOval(square);
      case BoxShape.rectangle:
        if (_decoration.borderRadius != null) {
          clipPath = Path()
            ..addRRect(
              _decoration.borderRadius!
                  .resolve(configuration.textDirection)
                  .toRRect(rect),
            );
        }
    }
    _imagePainter!.paint(canvas, rect, clipPath, configuration);
  }

  @override
  void dispose() {
    _imagePainter?.dispose();
    super.dispose();
  }

  /// Paint the box decoration into the given location on the given canvas.
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final TextDirection? textDirection = configuration.textDirection;
    _paintShadows(canvas, rect, textDirection);
    _paintBackgroundColor(canvas, rect, textDirection);
    _paintBackgroundImage(canvas, rect, configuration);
    _decoration.border?.paint(
      canvas,
      rect,
      shape: _decoration.shape,
      borderRadius: _decoration.borderRadius?.resolve(textDirection),
      textDirection: configuration.textDirection,
    );
  }

  @override
  String toString() {
    return 'BoxPainter for $_decoration';
  }
}
