import 'package:get/get.dart';
import '../../apis/client.dart';
import '../../apis/books_api.dart';
import '../../models/book_models.dart';
import '../../widgets/side_baner.dart';

class BookSearchController extends GetxController {
  final conditions = <BookSearchCondition>[].obs;
  final results = <BookDto>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final total = RxnInt();
  final limit = 20.obs; // 默认分页大小
  final offset = 0.obs;
  final hasMore = false.obs;
  final searching = false.obs; // 首次搜索按钮状态
  final advancedMode = false.obs; // 是否显示高级搜索面板
  final simpleQuery = ''.obs; // 简单搜索输入（匹配 title 标签）
  final selectedSimpleKey = 'TITLE'.obs; // 当前简单搜索使用的标签 KEY
  final simpleSuggestionsVisible = true.obs; // 是否显示简单候选

  Api get api => Get.find<Api>();

  void addCondition() {
    conditions.add(BookSearchCondition(target: '', op: 'eq', value: ''));
  }

  void removeCondition(int index) {
    if (index >= 0 && index < conditions.length) conditions.removeAt(index);
  }

  void updateCondition(int index, {String? target, String? op, String? value}) {
    if (index < 0 || index >= conditions.length) return;
    final old = conditions[index];
    conditions[index] = BookSearchCondition(
      target: target ?? old.target,
      op: op ?? old.op,
      value: value ?? old.value,
    );
  }

  Future<void> search({bool reset = true}) async {
    if (loading.value) return;
    searching.value = true;
    if (reset) {
      offset.value = 0;
      results.clear();
      total.value = null;
    }
    error.value = null;
    loading.value = true;
    try {
      final list = conditions.where((c) => c.target.trim().isNotEmpty).toList();
      final resp = await api.searchBooks(
        conditions: list,
        limit: limit.value,
        offset: offset.value,
      );
      if (reset) {
        results.assignAll(resp.items);
      } else {
        results.addAll(resp.items);
      }
      total.value = resp.total;
      // 计算是否还有更多
      if (resp.paged) {
        final fetched = offset.value + resp.items.length;
        hasMore.value = resp.total != null && fetched < resp.total!;
      } else {
        hasMore.value = false; // 非分页模式不支持加载更多
      }
    } catch (e) {
      error.value = '搜索失败';
      SideBanner.danger(error.value!);
    } finally {
      loading.value = false;
      searching.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || loading.value) return;
    offset.value += limit.value;
    await search(reset: false);
  }

  /// 简单模式搜索：按 title 标签做 match
  Future<void> searchSimple({bool reset = true}) async {
    // 默认使用 TITLE 做匹配
    await searchMatchKey('TITLE', reset: reset);
  }

  /// 根据指定标签 key (TITLE/AUTHOR/CLASS 等) 做 match 搜索
  Future<void> searchMatchKey(String key, {bool reset = true, String? valueOverride}) async {
    if (loading.value) return;
    searching.value = true;
    if (reset) {
      offset.value = 0;
      results.clear();
      total.value = null;
    }
    error.value = null;
    loading.value = true;
    try {
      final q = (valueOverride ?? simpleQuery.value).trim();
      final keyUp = key.toUpperCase();
      final List<BookSearchCondition> list = q.isEmpty
          ? []
          : [BookSearchCondition(target: keyUp, op: 'match', value: q)];
      final resp = await api.searchBooks(
        conditions: list,
        limit: limit.value,
        offset: offset.value,
      );
      if (reset) {
        results.assignAll(resp.items);
      } else {
        results.addAll(resp.items);
      }
      total.value = resp.total;
      if (resp.paged) {
        final fetched = offset.value + resp.items.length;
        hasMore.value = resp.total != null && fetched < resp.total!;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      error.value = '搜索失败';
      SideBanner.danger(error.value!);
    } finally {
      loading.value = false;
      searching.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // 直接响应输入变化：输入为空时清空结果
    ever<String>(simpleQuery, (val) {
      final q = val.trim();
      if (q.isEmpty) {
        results.clear();
        total.value = null;
        offset.value = 0;
        hasMore.value = false;
        simpleSuggestionsVisible.value = false;
      } else {
        // 有输入时显示候选（除非已被点击关闭重新输入会再打开）
        if (!simpleSuggestionsVisible.value) {
          simpleSuggestionsVisible.value = true;
        }
      }
    });
  }
}
