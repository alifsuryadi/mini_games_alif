import 'dart:math';

enum QuestionType {
  directIdentification, // "Place the marker on number X"
  addition, // "What is X + Y?"
  subtraction, // "What is X - Y?"
  midpoint, // "What number is halfway between X and Y?"
  gcf, // "What is the Greatest Common Factor of X and Y?"
  tutorial // Special type for tutorial
}

class QuestionModel {
  final int id;
  final String question;
  final int correctAnswer;
  final List<int> numberLineValues;
  final int minValue;
  final int maxValue;
  final int step;
  final QuestionType questionType;

  // For operation-based questions (addition, subtraction, etc.)
  final int? operand1;
  final int? operand2;

  // For tutorial questions
  final String? tutorialType;
  final String? tutorialInstructions;

  QuestionModel({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.numberLineValues,
    required this.minValue,
    required this.maxValue,
    required this.step,
    required this.questionType,
    this.operand1,
    this.operand2,
    this.tutorialType,
    this.tutorialInstructions,
  });

  // Factory constructor for tutorial questions
  factory QuestionModel.tutorial({
    required int id,
    required String question,
    required int correctAnswer,
    required List<int> numberLineValues,
    required int minValue,
    required int maxValue,
    required int step,
    required String tutorialType,
    int? operand1,
    int? operand2,
    String? tutorialInstructions,
  }) {
    return QuestionModel(
      id: id,
      question: question,
      correctAnswer: correctAnswer,
      numberLineValues: numberLineValues,
      minValue: minValue,
      maxValue: maxValue,
      step: step,
      questionType: QuestionType.tutorial,
      operand1: operand1,
      operand2: operand2,
      tutorialType: tutorialType,
      tutorialInstructions: tutorialInstructions ??
          'Drag the markers to answer the question. Click "Check Answer" when ready.',
    );
  }

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
    QuestionType questionType;
    if (maxValue <= 20) {
      // Easier levels focus on basic number identification and simple operations
      questionType = QuestionType.values[
          random.nextInt(3)]; // directIdentification, addition, subtraction
    } else if (maxValue <= 50) {
      // Medium levels include more operations
      questionType = QuestionType.values[random
          .nextInt(4)]; // directIdentification, addition, subtraction, midpoint
    } else {
      // Harder levels include all question types
      questionType =
          QuestionType.values[random.nextInt(5)]; // All except tutorial
    }

    // Generate target value that will be the correct answer
    int targetIndex = random.nextInt(values.length);
    int target = values[targetIndex];
    String questionText;

    int? operand1;
    int? operand2;

    switch (questionType) {
      case QuestionType.directIdentification:
        questionText = 'Place the marker on the number $target';
        break;

      case QuestionType.addition:
        // Generate addends that sum to target
        operand1 = target - step * (random.nextInt(3) + 1);
        if (operand1 < minValue) operand1 = minValue;
        operand2 = target - operand1;
        questionText = 'What is $operand1 + $operand2?';
        break;

      case QuestionType.subtraction:
        // Generate minuend and subtrahend for subtraction
        operand2 = step * (random.nextInt(3) + 1); // subtrahend
        operand1 = target + operand2; // minuend
        if (operand1 > maxValue) operand1 = maxValue;
        questionText = 'What is $operand1 - $operand2?';
        break;

      case QuestionType.midpoint:
        // Generate two numbers where target is their midpoint
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

        operand1 = lowerValue;
        operand2 = upperValue;
        questionText =
            'What number is halfway between $lowerValue and $upperValue?';
        break;

      case QuestionType.gcf:
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

        operand1 = num1;
        operand2 = num2;
        target = factor; // The GCF is the factor
        questionText = 'What is the Greatest Common Factor of $num1 and $num2?';
        break;

      case QuestionType.tutorial:
        // This case shouldn't happen in this factory method
        questionText = 'Place the marker on the number $target';
        break;
    }

    return QuestionModel(
      id: id,
      question: questionText,
      correctAnswer: target,
      numberLineValues: values,
      minValue: minValue,
      maxValue: maxValue,
      step: step,
      questionType: questionType,
      operand1: operand1,
      operand2: operand2,
    );
  }

  static List<int> _generateNumberLineValues(int min, int max, int step) {
    List<int> values = [];
    for (int i = min; i <= max; i += step) {
      values.add(i);
    }
    return values;
  }

  // Get initial positions for the sliders based on question type
  Map<String, double> getInitialSliderPositions() {
    final valueRange = maxValue - minValue;

    // Default positions (centered)
    double topPosition = 0.5;
    double downPosition = 0.5;
    double upPosition = 0.5;

    switch (questionType) {
      case QuestionType.directIdentification:
        // Both sliders at the same position
        final relativePos = (correctAnswer - minValue) / valueRange;
        topPosition = relativePos;
        downPosition = relativePos;
        upPosition = relativePos;
        break;

      case QuestionType.addition:
        if (operand1 != null) {
          // Down slider at first operand
          downPosition = (operand1! - minValue) / valueRange;
          // Initially place both markers at first operand
          upPosition = downPosition;
        }
        break;

      case QuestionType.subtraction:
        if (operand1 != null) {
          // Down slider at minuend (the larger number)
          downPosition = (operand1! - minValue) / valueRange;
          // Initially place both markers at first operand
          upPosition = downPosition;
        }
        break;

      case QuestionType.midpoint:
        if (operand1 != null && operand2 != null) {
          // Down slider at lower number
          downPosition = (operand1! - minValue) / valueRange;
          // Up slider at upper number
          upPosition = (operand2! - minValue) / valueRange;
          // Top slider midway
          topPosition = (downPosition + upPosition) / 2;
        }
        break;

      case QuestionType.gcf:
        // Place markers at default position
        break;

      case QuestionType.tutorial:
        if (tutorialType == 'marker_placement') {
          // Start with markers at the beginning
          downPosition = 0.0;
          upPosition = 0.0;
        } else if (tutorialType == 'addition' && operand1 != null) {
          // Down slider at first operand
          downPosition = (operand1! - minValue) / valueRange;
          // Up slider initially with down slider
          upPosition = downPosition;
        } else if (tutorialType == 'subtraction' && operand1 != null) {
          // Down slider at minuend
          downPosition = (operand1! - minValue) / valueRange;
          // Up slider initially with down slider
          upPosition = downPosition;
        }
        break;
    }

    return {
      'topPosition': topPosition,
      'downPosition': downPosition,
      'upPosition': upPosition,
    };
  }

  // Check if the answer is correct based on slider positions
  bool checkAnswer(double downPosition, double upPosition) {
    final valueRange = maxValue - minValue;
    final selectedDownValue = minValue + (valueRange * downPosition).round();
    final selectedUpValue = minValue + (valueRange * upPosition).round();

    switch (questionType) {
      case QuestionType.directIdentification:
        // Both triangles should be on the correct answer
        return selectedDownValue == correctAnswer &&
            selectedUpValue == correctAnswer;

      case QuestionType.addition:
        // Down triangle at first operand, up triangle at sum
        return operand1 != null &&
            selectedDownValue == operand1 &&
            selectedUpValue == correctAnswer;

      case QuestionType.subtraction:
        // Down triangle at minuend, up triangle at difference
        return operand1 != null &&
            selectedDownValue == operand1 &&
            selectedUpValue == correctAnswer;

      case QuestionType.midpoint:
        // Down triangle at lower value, up triangle at upper value
        return operand1 != null &&
            operand2 != null &&
            selectedDownValue == operand1 &&
            selectedUpValue == operand2;

      case QuestionType.gcf:
        // Either triangle at the correct answer
        return selectedDownValue == correctAnswer ||
            selectedUpValue == correctAnswer;

      case QuestionType.tutorial:
        if (tutorialType == 'marker_placement') {
          // Both triangles should be on the correct answer
          return selectedDownValue == correctAnswer &&
              selectedUpValue == correctAnswer;
        } else if (tutorialType == 'addition') {
          // Down triangle at first operand, up triangle at sum
          return operand1 != null &&
              selectedDownValue == operand1 &&
              selectedUpValue == correctAnswer;
        } else if (tutorialType == 'subtraction') {
          // Down triangle at minuend, up triangle at difference
          return operand1 != null &&
              selectedDownValue == operand1 &&
              selectedUpValue == correctAnswer;
        }
        return false;
    }
  }
}
