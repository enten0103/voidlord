class BookInfoModel {
  BookInfoModel({
    required this.id,
    required this.coverUrl,
    required this.title,
    this.subTitle,
    this.ssubTitle,
  });
  String id;
  String coverUrl;
  String title;
  String? subTitle;
  String? ssubTitle;

  factory BookInfoModel.fromJson(Map<String, dynamic> json) {
    return BookInfoModel(
      id: json['id'] as String,
      coverUrl: json['coverUrl'] as String,
      title: json['title'] as String,
      subTitle: json["subTitle"] as String,
      ssubTitle: json["ssubTitle"] as String,
    );
  }
  toMap() {
    return {
      'id': id,
      'coverUrl': coverUrl,
      'title': title,
      'subTitle': subTitle,
      'ssubTitle': ssubTitle,
    };
  }
}
