import 'package:voidlord/tono_reader/model/book_info.dart';

class BookBlockModel {
  BookBlockModel({
    required this.id,
    required this.title,
    required this.value,
    required this.books,
  });
  String id;
  String title;
  String value;
  List<BookInfoModel> books;
  factory BookBlockModel.fromJson(Map<String, dynamic> json) {
    return BookBlockModel(
      id: json['id'] as String,
      title: json['title'] as String,
      value: json['value'] as String,
      books: (json['books'] as List<dynamic>)
          .map((e) => BookInfoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
