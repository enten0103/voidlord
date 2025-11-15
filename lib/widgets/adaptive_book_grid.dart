import 'package:flutter/material.dart';
import '../models/book_models.dart';
import 'book_tile.dart';

/// 统一自适应书籍网格：用于搜索结果与上传列表
/// Breakpoints: <520:2, <720:3, <1024:4, >=1024:5 列
/// 间距统一 12，比例统一 0.72
class AdaptiveBookGrid extends StatelessWidget {
  final List<BookDto> books;
  final void Function(BookDto)? onTap;
  final void Function(BookDto)? onLongPress;
  final EdgeInsetsGeometry padding;
  final double childAspectRatio;

  const AdaptiveBookGrid({
    super.key,
    required this.books,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(12),
    this.childAspectRatio = 0.72,
  });

  int _computeColumns(double maxWidth) {
    if (maxWidth < 520) return 2;
    if (maxWidth < 720) return 3;
    if (maxWidth < 1024) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _computeColumns(constraints.maxWidth);
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: padding,
          itemCount: books.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (ctx, i) {
            final b = books[i];
            String title = '';
            String author = '';
            String? cover;
            for (final t in b.tags) {
              final k = t.key.toUpperCase();
              if (k == 'TITLE') title = t.value;
              if (k == 'AUTHOR') author = t.value;
              if (k == 'COVER') cover = t.value;
            }
            return BookTile(
              title: title,
              author: author,
              cover: cover,
              onTap: onTap == null ? null : () => onTap!(b),
              onLongPress: onLongPress == null ? null : () => onLongPress!(b),
            );
          },
        );
      },
    );
  }
}

/// Sliver 版本供上传页等使用，保持与 CustomScrollView 结构一致
class AdaptiveBookSliverGrid extends StatelessWidget {
  final List<BookDto> books;
  final void Function(BookDto)? onTap;
  final void Function(BookDto)? onLongPress;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;

  const AdaptiveBookSliverGrid({
    super.key,
    required this.books,
    this.onTap,
    this.onLongPress,
    this.childAspectRatio = 0.72,
    this.padding = const EdgeInsets.all(12),
  });

  int _computeColumns(double maxWidth) {
    if (maxWidth < 520) return 2;
    if (maxWidth < 720) return 3;
    if (maxWidth < 1024) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final columns = _computeColumns(constraints.crossAxisExtent);
        return SliverPadding(
          padding: padding,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final b = books[index];
              String title = '';
              String author = '';
              String? cover;
              for (final t in b.tags) {
                final k = t.key.toUpperCase();
                if (k == 'TITLE') title = t.value;
                if (k == 'AUTHOR') author = t.value;
                if (k == 'COVER') cover = t.value;
              }
              return BookTile(
                title: title,
                author: author,
                cover: cover,
                onTap: onTap == null ? null : () => onTap!(b),
                onLongPress: onLongPress == null ? null : () => onLongPress!(b),
              );
            }, childCount: books.length),
          ),
        );
      },
    );
  }
}
