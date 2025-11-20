import 'package:get/state_manager.dart';

class TonoProgresser extends GetxController {
  var pageIndex = 1.obs;

  int totalPageCount = 0;

  int currentPageIndex = 0;

  int xhtmlIndex = 0;

  List<int> pageSequence = [];

  List<int> elementSequence = [];

  var currentElementIndex = 0.obs;

  int totalElementCount = 0;
}
