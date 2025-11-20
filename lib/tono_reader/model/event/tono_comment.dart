class TonoComment {
  TonoComment({
    required this.comment,
  });
  final String comment;
  Map toJson() => {
        "comment": comment,
      };
  static TonoComment fromJson(Map json) {
    return TonoComment(
      comment: json["comment"] as String,
    );
  }
}
