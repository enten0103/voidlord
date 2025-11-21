import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class AsyncMemoryImage extends ImageProvider<AsyncMemoryImage> {
  final Future<Uint8List> dataFuture;
  final String cacheKey;
  final String? bookHash; // Add bookHash as a field

  AsyncMemoryImage(this.dataFuture, this.cacheKey, {this.bookHash});

  @override
  Future<AsyncMemoryImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AsyncMemoryImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    AsyncMemoryImage key,
    ImageDecoderCallback decode,
  ) {
    Future<Codec> codecFuture;

    codecFuture = key.dataFuture.then<Codec>(
      (data) => _decodeData(data, decode),
    );

    return MultiFrameImageStreamCompleter(
      codec: codecFuture,
      scale: 1.0,
      debugLabel: 'AsyncMemoryImage($cacheKey)',
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<String>('Cache key', cacheKey),
      ],
    );
  }

  Future<Codec> _decodeData(Uint8List data, ImageDecoderCallback decode) async {
    final buffer = await ImmutableBuffer.fromUint8List(data);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AsyncMemoryImage &&
        other.cacheKey == cacheKey &&
        other.bookHash == bookHash;
  }

  @override
  int get hashCode => Object.hash(cacheKey, bookHash);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'AsyncMemoryImage')}'
      '("$cacheKey", bookHash: "$bookHash")';
}
