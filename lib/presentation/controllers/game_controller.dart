import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mini_games_alif/data/repositories/game_repository.dart';
import 'package:mini_games_alif/domain/models/level_model.dart';
import 'package:mini_games_alif/domain/models/question_model.dart';
import 'package:mini_games_alif/domain/usecases/number_line_usecase.dart';

class GameController extends ChangeNotifier {
  final GameRepository _repository = GameRepository();
  final NumberLineUseCase _numberLineUseCase = NumberLineUseCase();

  LevelModel? _level;
  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedValue;
  bool _isCheckingAnswer = false;
  bool _isCorrect = false;
  int _score = 0;
  int _stars = 0;

  // Number line slider positions
  double _topSliderPosition = 0.5;
  double _downSliderPosition = 0.5;
  double _upSliderPosition = 0.5;

  // Zoom range for detailed view
  double _minOverallValue = 0.0;
  double _maxOverallValue = 0.0;
  double _minValue = 0.0;
  double _maxValue = 0.0;
  double _zoomWindowSize = 0.0;
  bool _isZoomModeEnabled = false;

  // Tutorial state
  bool _isTutorialMode = false;
  int _tutorialStep = 0;

  // Active sliders state
  bool _isTopSliderActive = false;
  bool _isDownSliderActive = false;
  bool _isUpSliderActive = false;

  // Getters
  LevelModel? get level => _level;
  List<QuestionModel> get questions => _questions;
  QuestionModel? get currentQuestion =>
      _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;
  int get currentQuestionIndex => _currentQuestionIndex;
  int? get selectedValue => _selectedValue;
  bool get isCheckingAnswer => _isCheckingAnswer;
  bool get isCorrect => _isCorrect;
  int get score => _score;
  int get stars => _stars;

  double get topSliderPosition => _topSliderPosition;
  double get downSliderPosition => _downSliderPosition;
  double get upSliderPosition => _upSliderPosition;

  double get minValue => _minValue;
  double get maxValue => _maxValue;
  bool get isZoomModeEnabled => _isZoomModeEnabled;

  bool get isTutorialMode => _isTutorialMode;
  int get tutorialStep => _tutorialStep;

  bool get isTopSliderActive => _isTopSliderActive;
  bool get isDownSliderActive => _isDownSliderActive;
  bool get isUpSliderActive => _isUpSliderActive;

  // Initialize game with level ID
  Future<void> initializeGame(int levelId) async {
    final level = _repository.getLevelById(levelId);
    if (level == null) return;

    _level = level;
    _questions = _repository.getQuestionsForLevel(levelId, count: 5);
    _currentQuestionIndex = 0;
    _selectedValue = null;
    _isCheckingAnswer = false;
    _isCorrect = false;
    _score = 0;
    _stars = 0;

    // Set up number line range - FIXED: explicit conversion to double
    _minOverallValue = level.minValue.toDouble();
    _maxOverallValue = level.maxValue.toDouble();

    // For zoomed mode, adjust window size based on level difficulty - FIXED: explicit conversion to double
    if (level.maxValue - level.minValue > 50) {
      // For larger ranges, show a smaller window to focus on details
      _zoomWindowSize = (level.maxValue - level.minValue).toDouble() / 5.0;
      _isZoomModeEnabled = true;
    } else {
      // For smaller ranges, just use the full range
      _zoomWindowSize = (level.maxValue - level.minValue).toDouble();
      _isZoomModeEnabled = false;
    }

    // Initialize number line with default values
    _minValue = level.minValue.toDouble();
    _maxValue = level.maxValue.toDouble();

    // Check if this is tutorial mode
    _isTutorialMode = level.levelId == 0;
    _tutorialStep = 0;

    // Set initial slider positions based on the current question
    if (currentQuestion != null) {
      final positions = currentQuestion!.getInitialSliderPositions();
      _topSliderPosition = positions['topPosition'] ?? 0.5;
      _downSliderPosition = positions['downPosition'] ?? 0.5;
      _upSliderPosition = positions['upPosition'] ?? 0.5;
    }

    notifyListeners();
  }

  // Handle top zoom slider movement
  void setTopSliderPosition(double position) {
    _topSliderPosition = position;
    _updateDetailViewRange();
    notifyListeners();
  }

  // Handle down marker triangle movement
  void setDownSliderPosition(double position) {
    _downSliderPosition = position;
    _selectedValue = _getValueFromPosition(position);
    notifyListeners();
  }

  // Handle up marker triangle movement
  void setUpSliderPosition(double position) {
    _upSliderPosition = position;
    _selectedValue = _getValueFromPosition(position);
    notifyListeners();
  }

  // Update slider active states
  void setTopSliderActive(bool isActive) {
    _isTopSliderActive = isActive;
    notifyListeners();
  }

  void setDownSliderActive(bool isActive) {
    _isDownSliderActive = isActive;
    notifyListeners();
  }

  void setUpSliderActive(bool isActive) {
    _isUpSliderActive = isActive;
    notifyListeners();
  }

  // Calculate value from slider position
  int _getValueFromPosition(double position) {
    // Use explicit double calculations then round to nearest step value
    final double rawValue = _minValue + ((_maxValue - _minValue) * position);
    if (_level == null) return rawValue.round();

    final int step = _level!.step;
    final int roundedValue = ((rawValue / step).round() * step);
    return roundedValue;
  }

  // Update the detail view range based on top slider position
  void _updateDetailViewRange() {
    if (!_isZoomModeEnabled) return;

    // Calculate center value based on slider position
    double centerValue = _minOverallValue +
        (_maxOverallValue - _minOverallValue) * _topSliderPosition;

    // Calculate min and max values based on center and zoom window size
    _minValue = centerValue - _zoomWindowSize / 2;
    _maxValue = centerValue + _zoomWindowSize / 2;

    // Ensure min and max stay within overall range
    if (_minValue < _minOverallValue) {
      _minValue = _minOverallValue;
      _maxValue = _minOverallValue + _zoomWindowSize;
    }
    if (_maxValue > _maxOverallValue) {
      _maxValue = _maxOverallValue;
      _minValue = _maxOverallValue - _zoomWindowSize;
    }

    notifyListeners();
  }

  // Check user's answer
  void checkAnswer() {
    if (currentQuestion == null) return;

    // Get the selected value on the number line
    final upValue = _getValueFromPosition(_upSliderPosition);
    final downValue = _getValueFromPosition(_downSliderPosition);

    // Check if answer is correct
    _isCheckingAnswer = true;
    _isCorrect =
        currentQuestion!.checkAnswer(_downSliderPosition, _upSliderPosition);

    if (_isCorrect) {
      _score += 20; // 20 points for each correct answer
    }

    notifyListeners();

    // Show feedback for 1.5 seconds, then continue to next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      _isCheckingAnswer = false;
      _selectedValue = null;

      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;

        // Set initial slider positions for the new question
        if (currentQuestion != null) {
          final positions = currentQuestion!.getInitialSliderPositions();
          _topSliderPosition = positions['topPosition'] ?? 0.5;
          _downSliderPosition = positions['downPosition'] ?? 0.5;
          _upSliderPosition = positions['upPosition'] ?? 0.5;
        }
      } else {
        _completeLevel();
      }

      notifyListeners();
    });
  }

  // For tutorial mode - advance to the next step
  void advanceTutorial() {
    _tutorialStep++;
    notifyListeners();
  }

  // Mark the level as complete
  void _completeLevel() {
    if (_level == null) return;

    // Calculate stars based on score (max 3 stars)
    if (_score >= 80) {
      _stars = 3;
    } else if (_score >= 60) {
      _stars = 2;
    } else if (_score >= 40) {
      _stars = 1;
    }

    // Update level completion in repository
    _repository.updateLevelCompletion(_level!.levelId, true, _stars);
  }

  // Find the nearest tick mark position (0-1 range)
  double findNearestTickPosition(double currentPosition) {
    if (_level == null) return currentPosition;

    // Calculate how many steps between min and max
    final double totalSteps = (_maxValue - _minValue) / _level!.step.toDouble();
    // Find nearest step
    final int nearestStep = (currentPosition * totalSteps).round();
    // Convert back to position
    return nearestStep / totalSteps;
  }
}
