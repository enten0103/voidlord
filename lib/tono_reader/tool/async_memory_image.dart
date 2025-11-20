import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/instance_manager.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';

class AsyncMemoryImage extends ImageProvider<AsyncMemoryImage> {
  final Future<Uint8List> dataFuture;
  final String cacheKey;

  AsyncMemoryImage(this.dataFuture, this.cacheKey);

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

  Future<Codec> _decodeData(
    Uint8List data,
    ImageDecoderCallback decode,
  ) async {
    final buffer = await ImmutableBuffer.fromUint8List(data);
    return decode(buffer);
  }

  int _generateHash() {
    try {
      return int.parse(
          "${cacheKey.hashCode}${Get.find<TonoProvider>().bookHash.hashCode}");
    } catch (e) {
      return cacheKey.hashCode;
    }
  }

  @override
  int get hashCode => _generateHash();

  @override
  String toString() => '${objectRuntimeType(this, 'AsyncMemoryImage')}'
      '("$cacheKey")';

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}
