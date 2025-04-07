class NumberLineUseCase {
  // Calculate the greatest common factor (GCF) of two numbers
  int calculateHCF(int a, int b) {
    // Ensure both values are positive
    a = a.abs();
    b = b.abs();

    // Use Euclidean algorithm to find GCF
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  // Calculate the midpoint between two numbers
  int calculateMidpoint(int a, int b) {
    return (a + b) ~/ 2;
  }

  // Calculate the result of addition
  int add(int a, int b) {
    return a + b;
  }

  // Calculate the result of subtraction
  int subtract(int a, int b) {
    return a - b;
  }

  // Check if a value is within a specified range
  bool isInRange(int value, int min, int max) {
    return value >= min && value <= max;
  }

  // Find the nearest value in a list to a given number
  int findNearestValue(int target, List<int> values) {
    if (values.isEmpty) return target;

    int nearest = values[0];
    int minDifference = (target - nearest).abs();

    for (int value in values) {
      int difference = (target - value).abs();
      if (difference < minDifference) {
        minDifference = difference;
        nearest = value;
      }
    }

    return nearest;
  }
}
