class NumberRepository {
  List<int> getNumbersInRange(int start, int end) {
    return List.generate(end - start + 1, (index) => start + index);
  }
}
