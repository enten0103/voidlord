class TonoSelectorPart {
  bool isUniversal = false;
  String? element;
  String? id;
  List<String> classes = [];
  List<String> pseudos = [];
  List<String> attributes = [];
  int get idCount => id != null ? 1 : 0;
  int get classCount => classes.length;
  int get attributeCount => attributes.length;
  int get elementCount => element != null ? 1 : 0;
  @override
  String toString() {
    List<String> parts = [];
    if (isUniversal) parts.add('Universal(*)');
    if (element != null) parts.add('Element($element)');
    if (id != null) parts.add('ID(#$id)');
    if (classes.isNotEmpty) parts.add('Classes(${classes.join(', ')})');
    if (pseudos.isNotEmpty) parts.add('Pseudos(${pseudos.join(', ')})');
    if (attributes.isNotEmpty) {
      parts.add('Attributes(${attributes.join(', ')})');
    }
    return parts.join(' + ');
  }
}
