typedef EqualityCheck<T> = bool Function(T a, T b);

extension ListToolExtension<T> on List<T> {
  /// Merges the current list with the target list based on a custom equality check.
  /// If an item in the target list is not found in the current list, it is added.
  /// If an item in the current list is found in the target list, it is moved to the same index.
  void merge(List<T> target, EqualityCheck<T> equals) {
    mergeListsCustom(target, this, equals);
  }
}

void mergeListsCustom<T>(
  List<T> current,
  List<T> target,
  EqualityCheck<T> equals,
) {
  int i = 0;
  while (i < target.length) {
    if (i < current.length) {
      if (equals(current[i], target[i])) {
        i++;
        continue;
      }
      int foundIndex = -1;
      for (int j = i; j < current.length; j++) {
        if (equals(current[j], target[i])) {
          foundIndex = j;
          break;
        }
      }
      if (foundIndex != -1) {
        final T item = current.removeAt(foundIndex);
        current.insert(i, item);
      } else {
        current.insert(i, target[i]);
      }
    } else {
      current.add(target[i]);
    }
    i++;
  }
  if (current.length > target.length) {
    current.removeRange(target.length, current.length);
  }
}
