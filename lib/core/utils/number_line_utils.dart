class NumberLineUtils {
  // Generate number steps based on start, end, and step
  static List<int> generateNumberSteps(int start, int end, int step) {
    List<int> numbers = [];
    for (int i = start; i <= end; i += step) {
      numbers.add(i);
    }
    return numbers;
  }

  // Calculate position on number line
  static double calculatePosition(
      double value, double min, double max, double width) {
    if (max == min) return 0;
    return ((value - min) / (max - min)) * width;
  }
}
