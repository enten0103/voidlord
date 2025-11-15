import 'package:flutter/material.dart';

/// 通用书籍展示组件：封面 + 标题 + 作者。
class BookTile extends StatelessWidget {
  final String title;
  final String author;
  final String? cover; // URL 或对象 key
  final VoidCallback? onTap;

  const BookTile({
    super.key,
    required this.title,
    required this.author,
    this.cover,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _buildCover(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title.isEmpty ? '未命名' : title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            author.isEmpty ? '-' : author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    if (cover == null || cover!.trim().isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.book, size: 32, color: Colors.black45),
        ),
      );
    }
    final value = cover!;
    final isUrl = value.startsWith('http://') || value.startsWith('https://');
    final src = isUrl ? value : 'http://localhost:9000/voidlord/$value';
    return Image.network(
      src,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
    );
  }
}
