class TonoStyle {
  TonoStyle({
    required this.priority,
    required this.value,
    required this.property,
  });

  ///属性
  final String property;

  ///值
  final String value;

  ///优先级
  final int priority;

  Map<String, dynamic> toMap() {
    return toJson();
  }

  static TonoStyle formMap(Map<String, dynamic> map) {
    return TonoStyle(
      priority: 0,
      value: map["value"] as String,
      property: map["property"] as String,
    );
  }

  ///不显示优先级
  Map<String, dynamic> toJson() {
    return {"property": property, "value": value, "priority": priority};
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
