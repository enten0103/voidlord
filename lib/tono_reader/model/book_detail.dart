import 'dart:convert';

import 'package:voidlord/tono_reader/model/book_info.dart';

class BookDetailModel {
  final String id;
  final BookDetailAbout? about;
  final BookDetailChapter? chapter;
  final BookDetailHead? head;
  final BookDetailSeries? series;
  final BookDetailStatistics? statistics;

  BookDetailModel({
    this.about,
    this.chapter,
    this.head,
    required this.id,
    this.series,
    this.statistics,
  });

  factory BookDetailModel.fromJson(String str) =>
      BookDetailModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BookDetailModel.fromMap(Map<String, dynamic> json) => BookDetailModel(
    about: json["about"] == null
        ? null
        : BookDetailAbout.fromMap(json["about"]),
    chapter: json["chapter"] == null
        ? null
        : BookDetailChapter.fromMap(json["chapter"]),
    head: json["head"] == null ? null : BookDetailHead.fromMap(json["head"]),
    id: json["id"],
    series: json["series"] == null
        ? null
        : BookDetailSeries.fromMap(json["series"]),
    statistics: json["statistics"] == null
        ? null
        : BookDetailStatistics.fromMap(json["statistics"]),
  );

  Map<String, dynamic> toMap() => {
    "about": about?.toMap(),
    "chapter": chapter?.toMap(),
    "head": head?.toMap(),
    "id": id,
    "series": series?.toMap(),
    "statistics": statistics?.toMap(),
  };
}

///book_detail_about
class BookDetailAbout {
  final String id;

  ///标签
  final List<BookDetailAboutRow> info;

  ///标签
  final List<BookTag> tags;

  final String value;

  BookDetailAbout({
    required this.id,
    required this.info,
    required this.tags,
    required this.value,
  });

  factory BookDetailAbout.fromJson(String str) =>
      BookDetailAbout.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BookDetailAbout.fromMap(Map<String, dynamic> json) => BookDetailAbout(
    id: json["id"],
    info: List<BookDetailAboutRow>.from(
      json["info"].map((x) => BookDetailAboutRow.fromMap(x)),
    ),
    tags: List<BookTag>.from(json["tags"].map((x) => BookTag.fromMap(x))),
    value: json["value"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "info": List<dynamic>.from(info.map((x) => x.toMap())),
    "tags": List<dynamic>.from(tags.map((x) => x.toMap())),
    "value": value,
  };
}

///book_detail_about_row
class BookDetailAboutRow {
  final String key;
  final List<BookTag> value;

  BookDetailAboutRow({required this.key, required this.value});

  factory BookDetailAboutRow.fromJson(String str) =>
      BookDetailAboutRow.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BookDetailAboutRow.fromMap(Map<String, dynamic> json) =>
      BookDetailAboutRow(
        key: json["key"],
        value: List<BookTag>.from(json["value"].map((x) => BookTag.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
    "key": key,
    "value": List<dynamic>.from(value.map((x) => x.toMap())),
  };
}

///BookTag
class BookTag {
  ///ID 编号
  final String id;

  ///名称
  final String value;

  BookTag({required this.id, required this.value});

  factory BookTag.fromJson(String str) => BookTag.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BookTag.fromMap(Map<String, dynamic> json) =>
      BookTag(id: json["id"], value: json["value"]);

  Map<String, dynamic> toMap() => {"id": id, "value": value};
}

///book_detail_chapter
class BookDetailChapter {
  final BookReadingProgress? progress;
  final List<BookChapter> value;

  BookDetailChapter({required this.progress, required this.value});

  factory BookDetailChapter.fromJson(String str) =>
      BookDetailChapter.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BookDetailChapter.fromMap(Map<String, dynamic> json) =>
      BookDetailChapter(
        progress: json["progress"] == null
            ? null
            : BookReadingProgress.fromMap(json["progress"]),
        value: List<BookChapter>.from(
          json["value"].map((x) => BookChapter.fromMap(x)),
        ),
      );

  Map<String, dynamic> toMap() => {
    "progress": progress?.toMap(),
    "value": List<dynamic>.from(value.map((x) => x.toMap())),
  };
}

///BookReadingProgress
class BookReadingProgress {
  final BookChapter chapter;
  final int readingProgress;

  BookReadingProgress({required this.chapter, required this.readingProgress});

  factory BookReadingProgress.fromJson(String str) =>
      BookReadingProgress.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BookReadingProgress.fromMap(Map<String, dynamic> json) =>
      BookReadingProgress(
        chapter: BookChapter.fromMap(json["chapter"]),
        readingProgress: json["readingProgress"],
      );

  Map<String, dynamic> toMap() => {
    "chapter": chapter.toMap(),
    "readingProgress": readingProgress,
  };
}

///BookChapter
class BookChapter {
  ///ID 编号
  final String id;

  ///名称
  final String name;

  BookChapter({required this.id, required this.name});

  factory BookChapter.fromJson(String str) =>
      BookChapter.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BookChapter.fromMap(Map<String, dynamic> json) =>
      BookChapter(id: json["id"], name: json["name"]);

  Map<String, dynamic> toMap() => {"id": id, "name": name};
}

///book_detail_head
class BookDetailHead {
  final String id;
  final Author? author;
  final List<String>? customize;
  final Publisher? publisher;
  final String title;

  BookDetailHead({
    required this.id,
    required this.title,
    this.author,
    this.customize,
    this.publisher,
  });

  factory BookDetailHead.fromJson(String str) =>
      BookDetailHead.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BookDetailHead.fromMap(Map<String, dynamic> json) => BookDetailHead(
    id: json["id"],
    author: json["author"] == null ? null : Author.fromMap(json["author"]),
    customize: json["customize"] == null
        ? []
        : List<String>.from(json["customize"]!.map((x) => x)),
    publisher: json["publisher"] == null
        ? null
        : Publisher.fromMap(json["publisher"]),
    title: json["title"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "author": author?.toMap(),
    "customize": customize == null
        ? []
        : List<dynamic>.from(customize!.map((x) => x)),
    "publisher": publisher?.toMap(),
    "title": title,
  };
}

class Author {
  final String value;
  final String id;

  Author({required this.id, required this.value});

  factory Author.fromJson(String str) => Author.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Author.fromMap(Map<String, dynamic> json) =>
      Author(id: json["id"], value: json["value"]);

  Map<String, dynamic> toMap() => {"id": id, "value": value};
}

class Publisher {
  final String value;
  final String id;

  Publisher({required this.id, required this.value});

  factory Publisher.fromJson(String str) => Publisher.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Publisher.fromMap(Map<String, dynamic> json) =>
      Publisher(id: json["id"], value: json["value"]);

  Map<String, dynamic> toMap() => {"id": id, "value": value};
}

class BookDetailSeries {
  final String id;
  final List<BookInfoModel> books;
  final String title;

  BookDetailSeries({
    required this.books,
    required this.id,
    required this.title,
  });

  factory BookDetailSeries.fromJson(String str) =>
      BookDetailSeries.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BookDetailSeries.fromMap(Map<String, dynamic> json) =>
      BookDetailSeries(
        books: List<BookInfoModel>.from(
          json["books"].map((x) => BookInfoModel.fromJson(x)),
        ),
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toMap() => {
    "books": List<dynamic>.from(books.map((x) => x.toMap())),
    "id": id,
    "title": title,
  };
}

///book_detail_statistics
class BookDetailStatistics {
  final String id;
  final int collections;
  final int comments;
  final bool hasCollected;
  final double score;
  final String type;

  BookDetailStatistics({
    required this.id,
    required this.collections,
    required this.comments,
    required this.hasCollected,
    required this.score,
    required this.type,
  });

  factory BookDetailStatistics.fromJson(String str) =>
      BookDetailStatistics.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BookDetailStatistics.fromMap(Map<String, dynamic> json) =>
      BookDetailStatistics(
        id: json["id"],
        collections: json["collections"],
        comments: json["comments"],
        hasCollected: json["hasCollected"],
        score: json["score"]?.toDouble(),
        type: json["type"],
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "collections": collections,
    "comments": comments,
    "hasCollected": hasCollected,
    "score": score,
    "type": type,
  };
}
