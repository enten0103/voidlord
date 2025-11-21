import 'package:flutter/material.dart';
import 'package:get/get.dart';
// book_models.dart 未直接引用具体类型（仅通过 BookSearchController.results 访问），无需导入
import '../../widgets/side_baner.dart';
import '../../routes/app_routes.dart';
import 'book_search_controller.dart';
import '../../apis/books_api.dart';

class BookSearchPage extends GetView<BookSearchController> {
  const BookSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (ctx, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _simpleSearchBar(context),
              Obx(
                () => controller.advancedMode.value
                    ? const SizedBox(height: 24)
                    : const SizedBox(),
              ),
              Obx(
                () => controller.advancedMode.value
                    ? _advancedPanelReactive(context)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 高级面板：采用细粒度 Obx，避免整块重建导致输入抖动
  Widget _advancedPanelReactive(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头部操作行：仅按钮和清空状态需要响应
        Row(
          children: [
            Obx(
              () => FilledButton.icon(
                onPressed: controller.loading.value
                    ? null
                    : () => controller.addCondition(),
                icon: const Icon(Icons.add),
                label: const Text('添加条件'),
              ),
            ),
            const Spacer(),
            Obx(() {
              if (controller.conditions.isEmpty) return const SizedBox();
              return TextButton(
                onPressed: controller.loading.value
                    ? null
                    : () => controller.conditions.clear(),
                child: const Text('清空'),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),
        // 条件列表：单独监听，减少与头部/尾部耦合
        Obx(() {
          return Column(
            children: List.generate(
              controller.conditions.length,
              (i) => _ConditionInputRow(
                key: Key(controller.conditions[i].id),
                index: i,
                condition: controller.conditions[i],
                controller: controller,
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        // 搜索操作区：加载态和 limit 修改仅影响本行
        Obx(
          () => Row(
            children: [
              FilledButton.icon(
                onPressed: controller.loading.value
                    ? null
                    : () {
                        if (controller.conditions.isEmpty) {
                          SideBanner.warning('请添加搜索条件');
                          return;
                        }
                        Get.toNamed(
                          Routes.mediaLibraryDetail,
                          arguments: {
                            'searchConditions': controller.conditions.toList(),
                          },
                        );
                      },
                icon: const Icon(Icons.tune),
                label: const Text('按条件搜索'),
              ),
              const SizedBox(width: 12),
              if (controller.loading.value)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              const Spacer(),
              SizedBox(
                width: 80,
                child: TextField(
                  enabled: !controller.loading.value,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '每页'),
                  controller:
                      TextEditingController(
                          text: controller.limit.value.toString(),
                        )
                        ..selection = TextSelection.fromPosition(
                          TextPosition(
                            offset: controller.limit.value.toString().length,
                          ),
                        ),
                  onSubmitted: (v) {
                    final n = int.tryParse(v.trim());
                    if (n != null && n > 0 && n <= 100) {
                      controller.limit.value = n;
                    } else {
                      SideBanner.warning('范围 1~100');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _simpleSearchBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.simpleTextController,
          enabled: !controller.loading.value,
          decoration: InputDecoration(
            labelText: '输入关键字，点击候选搜索',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: Obx(
              () => TextButton(
                onPressed: controller.loading.value
                    ? null
                    : () => controller.advancedMode.toggle(),
                child: Text(controller.advancedMode.value ? '收起高级' : '高级搜索'),
              ),
            ),
          ),
          onChanged: (v) {
            String raw = v;
            for (final p in ['标题：', '作者：', '分类：']) {
              if (raw.startsWith(p)) {
                raw = raw.substring(p.length);
                break;
              }
            }
            controller.simpleQuery.value = raw;
            controller.simpleSuggestionsVisible.value = true;
          },
        ),
        const SizedBox(height: 6),
        _suggestionsReactive(context),
        if (controller.loading.value)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Widget _suggestionsReactive(BuildContext context) {
    return Obx(() {
      final q = controller.simpleQuery.value.trim();
      if (q.isEmpty || !controller.simpleSuggestionsVisible.value) {
        return const SizedBox();
      }
      final active = controller.selectedSimpleKey.value;
      final List<_Candidate> list = [
        _Candidate(
          label: '标题',
          key: 'TITLE',
          display: '标题：$q',
          active: active == 'TITLE',
        ),
        _Candidate(
          label: '作者',
          key: 'AUTHOR',
          display: '作者：$q',
          active: active == 'AUTHOR',
        ),
        _Candidate(
          label: '分类',
          key: 'CLASS',
          display: '分类：$q',
          active: active == 'CLASS',
        ),
      ];
      return Column(
        children: [
          for (final c in list)
            InkWell(
              onTap: controller.loading.value
                  ? null
                  : () {
                      controller.selectedSimpleKey.value = c.key;
                      controller.simpleQuery.value = c.display;
                      controller.simpleSuggestionsVisible.value = false;

                      final keyUp = c.key.toUpperCase();
                      final list = [
                        BookSearchCondition(
                          target: keyUp,
                          op: 'match',
                          value: q,
                        ),
                      ];
                      Get.toNamed(
                        Routes.mediaLibraryDetail,
                        arguments: {'searchConditions': list},
                      );
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: c.active
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.10)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 0.7,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      c.active ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: c.active
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c.display,
                        style: c.active
                            ? const TextStyle(fontWeight: FontWeight.w600)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _ConditionInputRow extends StatefulWidget {
  final int index;
  final BookSearchCondition condition;
  final BookSearchController controller;

  const _ConditionInputRow({
    super.key,
    required this.index,
    required this.condition,
    required this.controller,
  });

  @override
  State<_ConditionInputRow> createState() => _ConditionInputRowState();
}

class _ConditionInputRowState extends State<_ConditionInputRow> {
  late final TextEditingController _targetController;
  late final TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _targetController = TextEditingController(text: widget.condition.target);
    _valueController = TextEditingController(text: widget.condition.value);
  }

  @override
  void dispose() {
    _targetController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ConditionInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.condition.target != _targetController.text) {
      _targetController.text = widget.condition.target;
    }
    if (widget.condition.value != _valueController.text) {
      _valueController.text = widget.condition.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ops = ['eq', 'neq', 'match'];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: TextField(
                controller: _targetController,
                decoration: const InputDecoration(labelText: '标签 Key'),
                onChanged: (v) => widget.controller.updateCondition(
                  widget.index,
                  target: v.trim(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: widget.condition.op,
              items: ops
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  widget.controller.updateCondition(widget.index, op: v);
                }
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: '值'),
                onChanged: (v) =>
                    widget.controller.updateCondition(widget.index, value: v),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: '删除',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => widget.controller.removeCondition(widget.index),
            ),
          ],
        ),
      ),
    );
  }
}

class _Candidate {
  final String label; // 描述性标签
  final String key; // 用于后端搜索的 KEY
  final String display; // 展示内容
  final bool active; // 是否为当前选中
  _Candidate({
    required this.label,
    required this.key,
    required this.display,
    this.active = false,
  });
}
