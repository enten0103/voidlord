class TonoBookInfo {
  const TonoBookInfo({
    required this.title,
    required this.coverUrl,
  });

  final String title;
  final String coverUrl;
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'coverUrl': coverUrl,
    };
  }

  static TonoBookInfo fromMap(Map<String, dynamic> map) {
    return TonoBookInfo(
      title: map['title'] as String,
      coverUrl: map['coverUrl'] as String,
    );
  }
}

class TonoNavItem {
  const TonoNavItem({
    required this.path,
    required this.title,
  });
  final String path;
  final String title;
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'title': title,
    };
  }

  static TonoNavItem fromMap(Map<String, dynamic> map) {
    return TonoNavItem(
      path: map['path'] as String,
      title: map['title'] as String,
    );
  }
}
