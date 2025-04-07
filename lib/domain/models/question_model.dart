import 'dart:math';

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
    final Random random = Random();
    final List<int> values =
        _generateNumberLineValues(minValue, maxValue, step);

    // Question type selection based on level difficulty
    int questionType;
    if (maxValue <= 20) {
      // Easier levels focus on basic number identification
      questionType = random.nextInt(2); // 0-1
    } else if (maxValue <= 50) {
      // Medium levels include more operations
      questionType = random.nextInt(3) + 1; // 1-3
    } else {
      // Harder levels include all question types
      questionType = random.nextInt(5); // 0-4
    }

    // Generate target value that will be the correct answer
    int targetIndex = random.nextInt(values.length);
    int target = values[targetIndex];
    String questionText;

    switch (questionType) {
      case 0: // Direct number identification
        questionText = 'Place the marker on the number $target';
        break;

      case 1: // Addition
        int addend1 = target - step * (random.nextInt(3) + 1);
        if (addend1 < minValue) addend1 = minValue;
        int addend2 = target - addend1;
        questionText = 'What is $addend1 + $addend2?';
        break;

      case 2: // Subtraction
        int subtrahend = step * (random.nextInt(3) + 1);
        int minuend = target + subtrahend;
        if (minuend > maxValue) minuend = maxValue;
        questionText = 'What is $minuend - $subtrahend?';
        break;

      case 3: // Midpoint/halfway
        int lowerValue = target - (step * (random.nextInt(3) + 1));
        int upperValue = target + (step * (random.nextInt(3) + 1));
        if (lowerValue < minValue) lowerValue = minValue;
        if (upperValue > maxValue) upperValue = maxValue;

        // Ensure target is actually the midpoint
        target = (lowerValue + upperValue) ~/ 2;
        // Ensure the midpoint is on the number line (divisible by step)
        if (target % step != 0) {
          // Adjust the upper value to make midpoint valid
          upperValue = target * 2 - lowerValue;
          if (upperValue > maxValue) {
            // If upper value exceeds max, adjust lower value instead
            upperValue = maxValue;
            lowerValue = 2 * target - upperValue;
          }
        }

        questionText =
            'What number is halfway between $lowerValue and $upperValue?';
        break;

      case 4: // Greatest Common Factor (for advanced levels)
        // Make sure the numbers have a non-trivial GCF
        int factor = step * (random.nextInt(3) + 2); // Common factor
        int multiple1 = (random.nextInt(5) + 2); // First multiple
        int multiple2 = (random.nextInt(3) + 2); // Second multiple

        int num1 = factor * multiple1;
        int num2 = factor * multiple2;

        // Ensure numbers are within range
        while (num1 > maxValue || num2 > maxValue) {
          if (multiple1 > multiple2) {
            multiple1--;
          } else {
            multiple2--;
          }
          num1 = factor * multiple1;
          num2 = factor * multiple2;
        }

        target = factor; // The GCF is the factor
        questionText =
            'What is the highest Greatest Common Factor between $num1 and $num2?';
        break;

      default:
        // Default to simple identification
        questionText = 'Place the marker on the number $target';
    }

    return QuestionModel(
      id: id,
      question: questionText,
      correctAnswer: target,
      numberLineValues: values,
      minValue: minValue,
      maxValue: maxValue,
      step: step,
    );
  }

  static List<int> _generateNumberLineValues(int min, int max, int step) {
    List<int> values = [];
    for (int i = min; i <= max; i += step) {
      values.add(i);
    }
    return values;
  }
}
