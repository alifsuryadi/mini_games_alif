class QuestionModel {
  final int id;
  final String question;
  final int correctAnswer;
  final List<int> numberLineValues;
  final int minValue;
  final int maxValue;
  final int step;

  QuestionModel({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.numberLineValues,
    required this.minValue,
    required this.maxValue,
    required this.step,
  });

  factory QuestionModel.generateFromLevel({
    required int id,
    required int minValue,
    required int maxValue,
    required int step,
  }) {
    final int target = _generateRandomNumber(minValue, maxValue, step);
    final List<int> values =
        _generateNumberLineValues(minValue, maxValue, step);

    return QuestionModel(
      id: id,
      question:
          'What is the highest Greatest Common Factor between these 2 values:',
      correctAnswer: target,
      numberLineValues: values,
      minValue: minValue,
      maxValue: maxValue,
      step: step,
    );
  }

  static int _generateRandomNumber(int min, int max, int step) {
    // Generate a random number within range that is divisible by step
    final range = (max - min) ~/ step;
    final random = min + (DateTime.now().millisecondsSinceEpoch % range) * step;
    return random;
  }

  static List<int> _generateNumberLineValues(int min, int max, int step) {
    List<int> values = [];
    for (int i = min; i <= max; i += step) {
      values.add(i);
    }
    return values;
  }
}
