import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadDialogController extends GetxController {
  DownloadDialogController({required this.url, required this.savePath});
  final String url;
  final String savePath;

  final RxInt received = 0.obs;
  final RxInt total = 0.obs;
  final RxString info = ''.obs;

  double get progress => total.value > 0 ? received.value / total.value : 0.0;

  @override
  void onReady() async {
    super.onReady();
    try {
      final client = dio.Dio();
      await client.download(
        url,
        savePath,
        onReceiveProgress: (r, t) {
          received.value = r;
          total.value = t;
          if (t > 0) {
            final percent = (r * 100 ~/ t);
            info.value = '已下载 $percent%';
          }
        },
      );
      await Future.delayed(const Duration(milliseconds: 150));
      Get.back<bool>(result: true);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 150));
      Get.back<bool>(result: false);
    }
  }
}

class DownloadDialog extends StatelessWidget {
  const DownloadDialog({super.key, required this.url, required this.savePath});
  final String url;
  final String savePath;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DownloadDialogController(url: url, savePath: savePath));
    return Obx(
      () => Dialog(
        elevation: 19,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: Get.mediaQuery.size.width,
            maxHeight: 110,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '正在下载… ${c.info.value}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                        '${_fmtSize(c.received.value)} / ${_fmtSize(c.total.value)}'),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: c.progress.isNaN ? null : c.progress.clamp(0.0, 1.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmtSize(int bytes) {
    if (bytes <= 0) return '0B';
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;
    if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(2)}GB';
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(2)}MB';
    if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(2)}KB';
    return '${bytes}B';
  }
}
