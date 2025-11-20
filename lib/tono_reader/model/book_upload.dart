class BookUploadModule {
  final int id;
  final String title;
  final String bookhash;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookUploadModule({
    required this.id,
    required this.title,
    required this.bookhash,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookUploadModule.fromJson(Map<String, dynamic> json) {
    return BookUploadModule(
      id: json['id'] as int,
      title: json['title'] as String,
      bookhash: json['bookhash'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  toJson() {
    return {
      'id': id,
      'title': title,
      'bookhash': bookhash,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
