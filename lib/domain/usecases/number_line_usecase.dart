class NumberLineUseCase {
  // Logic for calculating the highest common factor on the number line
  int calculateHCF(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }
}
