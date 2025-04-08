import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_games_alif/core/styles/app_colors.dart';
import 'package:mini_games_alif/core/styles/app_sizes.dart';
import 'package:mini_games_alif/core/styles/card_colors/card_colors.dart';
import 'package:mini_games_alif/data/repositories/game_repository.dart';
import 'package:mini_games_alif/domain/models/level_model.dart';
import 'package:mini_games_alif/domain/models/question_model.dart';
import 'package:mini_games_alif/domain/usecases/number_line_usecase.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  final GameRepository _repository = GameRepository();
  final NumberLineUseCase _numberLineUseCase = NumberLineUseCase();

  late LevelModel _level;
  late List<QuestionModel> _questions;
  int _currentQuestionIndex = 0;
  int? _selectedValue;
  bool _isCheckingAnswer = false;
  bool _isCorrect = false;
  int _score = 0;
  int _stars = 0;

  // Tutorial state
  bool _isTutorialMode = false;
  int _tutorialStep = 0;

  // Variables for the number line
  double _topSliderPosition = 0.5; // Temperature-like slider
  double _downSliderPosition = 0.5; // Down triangle slider
  double _upSliderPosition = 0.5; // Up triangle slider

  // Target positions for animated snapping
  double _downSliderTargetPosition = 0.5;
  double _upSliderTargetPosition = 0.5;

  // Animation controllers for slider snapping animation
  late AnimationController _downSliderSnapController;
  late AnimationController _upSliderSnapController;
  late Animation<double> _downSliderSnapAnimation;
  late Animation<double> _upSliderSnapAnimation;

  // State for active sliders
  bool _isTopSliderActive = false;
  bool _isDownSliderActive = false;
  bool _isUpSliderActive = false;

  // Number line values - we'll make these dynamic based on slider position
  double _minValue = 0.0;
  double _maxValue = 0.0;

  // Zoom range (the overall range for the zoomed-out view)
  double _minOverallValue = 1600.0;
  double _maxOverallValue = 1700.0;

  // Zoom window size (the width of the visible range in the detail view)
  double _zoomWindowSize = 10.0;

  // Animation controllers for hover effects
  late AnimationController _topSliderController;
  late AnimationController _downSliderController;
  late AnimationController _upSliderController;
  late Animation<double> _topSliderAnimation;
  late Animation<double> _downSliderAnimation;
  late Animation<double> _upSliderAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers with faster duration
    _topSliderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _downSliderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _upSliderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Initialize snap animation controllers
    _downSliderSnapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _upSliderSnapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Define hover animations
    _topSliderAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _topSliderController, curve: Curves.easeOut));
    _downSliderAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _downSliderController, curve: Curves.easeOut));
    _upSliderAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _upSliderController, curve: Curves.easeOut));

    // The snap animations will be initialized later when we know the start and end positions
    _downSliderSnapAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _downSliderSnapController, curve: Curves.easeOutBack));
    _upSliderSnapAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _upSliderSnapController, curve: Curves.easeOutBack));

    // Add snap animation listeners
    _downSliderSnapController.addListener(_updateDownSliderSnap);
    _upSliderSnapController.addListener(_updateUpSliderSnap);

    // Set initial position to match the main number line values
    _topSliderPosition = 0.5; // Start in the middle
    _downSliderTargetPosition = 0.5;
    _upSliderTargetPosition = 0.5;

    // Calculate the initial min and max values for the detail view
    _updateDetailViewRange();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  // Calculate the min and max values for the detail view based on top slider position
  void _updateDetailViewRange() {
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
  }

  // Snap animation update listeners
  void _updateDownSliderSnap() {
    if (!_downSliderSnapController.isAnimating) return;

    setState(() {
      double startPosition =
          _downSliderSnapAnimation.value == 0 ? _downSliderPosition : 0;
      double endPosition = _downSliderTargetPosition;
      _downSliderPosition = startPosition +
          (_downSliderSnapAnimation.value * (endPosition - startPosition));
    });
  }

  void _updateUpSliderSnap() {
    if (!_upSliderSnapController.isAnimating) return;

    setState(() {
      double startPosition =
          _upSliderSnapAnimation.value == 0 ? _upSliderPosition : 0;
      double endPosition = _upSliderTargetPosition;
      _upSliderPosition = startPosition +
          (_upSliderSnapAnimation.value * (endPosition - startPosition));
    });
  }

  // Find the nearest tick mark position (0-1 range)
  double _findNearestTickPosition(double currentPosition) {
    // For 11 tick marks (0-10 inclusive), we have 10 segments
    int nearestTick = (currentPosition * 10).round();
    return nearestTick / 10;
  }

  // Animate slider to snap to nearest tick mark
  void _snapDownSliderToNearestTick() {
    _downSliderTargetPosition = _findNearestTickPosition(_downSliderPosition);

    // Configure animation
    _downSliderSnapController.reset();
    _downSliderSnapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _downSliderSnapController,
      curve: Curves.easeOutBack,
    ));

    _downSliderSnapController.forward();
  }

  // Animate slider to snap to nearest tick mark
  void _snapUpSliderToNearestTick() {
    _upSliderTargetPosition = _findNearestTickPosition(_upSliderPosition);

    // Configure animation
    _upSliderSnapController.reset();
    _upSliderSnapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _upSliderSnapController,
      curve: Curves.easeOutBack,
    ));

    _upSliderSnapController.forward();
  }

  @override
  void dispose() {
    _topSliderController.dispose();
    _downSliderController.dispose();
    _upSliderController.dispose();
    _downSliderSnapController.dispose();
    _upSliderSnapController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final levelId = args != null ? args['levelId'] as int : 1;

    _level = _repository.getLevelById(levelId)!;
    _questions = _repository.getQuestionsForLevel(levelId, count: 5);

    // Set tutorial mode for level 0
    _isTutorialMode = levelId == 0;
    _tutorialStep = 0;

    // Set initial slider positions based on question type
    _setupInitialSliderPositions();

    // Fix for the error - Convert integer to double explicitly
    _zoomWindowSize = (_level.maxValue - _level.minValue).toDouble();

    // Set the overall range based on the level
    _minOverallValue = _level.minValue.toDouble();
    _maxOverallValue = _level.maxValue.toDouble();

    // Update the detail view range
    _updateDetailViewRange();

    setState(() {});
  }

  void _setupInitialSliderPositions() {
    if (_questions.isEmpty) return;

    final question = _questions[_currentQuestionIndex];

    switch (question.questionType) {
      case QuestionType.directIdentification:
        // Position both sliders at the same place
        _downSliderPosition = 0.5;
        _upSliderPosition = 0.5;
        break;

      case QuestionType.addition:
        // If there's an operand1, position down slider there
        if (question.operand1 != null) {
          // Calculate the relative position on the number line
          final totalRange = _level.maxValue - _level.minValue;
          final relativePos =
              ((question.operand1! - _level.minValue) / totalRange)
                  .clamp(0.0, 1.0);
          _downSliderPosition = relativePos;
          _upSliderPosition = relativePos; // Start both at same position
        }
        break;

      case QuestionType.subtraction:
        // If there's an operand1, position down slider there
        if (question.operand1 != null) {
          final totalRange = _level.maxValue - _level.minValue;
          final relativePos =
              ((question.operand1! - _level.minValue) / totalRange)
                  .clamp(0.0, 1.0);
          _downSliderPosition = relativePos;
          _upSliderPosition = relativePos; // Start both at same position
        }
        break;

      case QuestionType.midpoint:
        // If there are both operands, position sliders at respective points
        if (question.operand1 != null && question.operand2 != null) {
          final totalRange = _level.maxValue - _level.minValue;
          final relativePos1 =
              ((question.operand1! - _level.minValue) / totalRange)
                  .clamp(0.0, 1.0);
          final relativePos2 =
              ((question.operand2! - _level.minValue) / totalRange)
                  .clamp(0.0, 1.0);
          _downSliderPosition = relativePos1;
          _upSliderPosition = relativePos2;
        }
        break;

      case QuestionType.gcf:
        // For GCF, place sliders in default position
        _downSliderPosition = 0.3;
        _upSliderPosition = 0.7;
        break;

      default:
        _downSliderPosition = 0.5;
        _upSliderPosition = 0.5;
    }
  }

  int _getValueFromPosition(double position) {
    // Calculate value at position on number line
    final rangeSize = _maxValue - _minValue;
    final rawValue = _minValue + (rangeSize * position);

    // For direct number identification, we want exact steps
    if (_level.step > 1) {
      // Round to nearest step
      return ((rawValue / _level.step).round() * _level.step);
    }

    return rawValue.round();
  }

  // Calculate visible range for zoomed-out view
  double _calculateZoomViewPosition(double zoomPosition) {
    // Convert the zoom position to a value in the overall range
    double totalRange = _maxOverallValue - _minOverallValue;

    // Calculate the zoom window center value (in the number range)
    double zoomedValue = _minValue + ((_maxValue - _minValue) * zoomPosition);

    // Calculate the position of this value in the overall range
    return (zoomedValue - _minOverallValue) / totalRange;
  }

  void _checkAnswer() {
    if (_questions.isEmpty) return;

    final question = _questions[_currentQuestionIndex];
    int? correctAnswer;

    switch (question.questionType) {
      case QuestionType.directIdentification:
        // For direct identification, the answer is simply the target number
        correctAnswer = question.correctAnswer;
        _isCorrect =
            _getValueFromPosition(_downSliderPosition) == correctAnswer &&
                _getValueFromPosition(_upSliderPosition) == correctAnswer;
        break;

      case QuestionType.addition:
        // For addition, down triangle should be at first operand, up triangle at sum
        if (question.operand1 != null) {
          correctAnswer = question.correctAnswer;
          _isCorrect =
              _getValueFromPosition(_downSliderPosition) == question.operand1 &&
                  _getValueFromPosition(_upSliderPosition) == correctAnswer;
        }
        break;

      case QuestionType.subtraction:
        // For subtraction, down triangle should be at minuend, up triangle at difference
        if (question.operand1 != null) {
          correctAnswer = question.correctAnswer;
          _isCorrect =
              _getValueFromPosition(_downSliderPosition) == question.operand1 &&
                  _getValueFromPosition(_upSliderPosition) == correctAnswer;
        }
        break;

      case QuestionType.midpoint:
        // For midpoint, down triangle should be at lower number, up triangle at upper number
        if (question.operand1 != null && question.operand2 != null) {
          // The midpoint itself is the correct answer, but we need both triangles positioned correctly
          _isCorrect =
              _getValueFromPosition(_downSliderPosition) == question.operand1 &&
                  _getValueFromPosition(_upSliderPosition) == question.operand2;
        }
        break;

      case QuestionType.gcf:
        // For GCF, either triangle should be at the correct answer
        correctAnswer = question.correctAnswer;
        _isCorrect =
            _getValueFromPosition(_downSliderPosition) == correctAnswer ||
                _getValueFromPosition(_upSliderPosition) == correctAnswer;
        break;

      default:
        _isCorrect = false;
    }

    setState(() {
      _isCheckingAnswer = true;
      _selectedValue = _getValueFromPosition(_upSliderPosition);

      if (_isCorrect) {
        _score += 20; // 20 points for each correct answer
      }
    });

    // Show feedback for 1.5 seconds, then continue to next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      setState(() {
        _isCheckingAnswer = false;
        _selectedValue = null;

        if (_currentQuestionIndex < _questions.length - 1) {
          _currentQuestionIndex++;
          _setupInitialSliderPositions(); // Set positions for new question
        } else {
          _completeLevel();
        }
      });
    });
  }

  void _completeLevel() {
    // Calculate stars based on score (max 3 stars)
    if (_score >= 80) {
      _stars = 3;
    } else if (_score >= 60) {
      _stars = 2;
    } else if (_score >= 40) {
      _stars = 1;
    }

    // Update level completion in repository
    _repository.updateLevelCompletion(_level.levelId, true, _stars);

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Level Completed!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $_score',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < _stars ? Icons.star : Icons.star_border,
                  color: index < _stars ? AppColors.numberYellow : Colors.grey,
                  size: 36.sp,
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to level selection
            },
            child: Text(
              'Continue',
              style: TextStyle(
                color: const Color.fromARGB(255, 2, 8, 20),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Advance to next tutorial step
  void _advanceTutorial() {
    setState(() {
      _tutorialStep++;
      if (_tutorialStep > 3) {
        // After all 4 tutorial steps
        _tutorialStep = 0; // Reset for next question
        _isTutorialMode = false; // Exit tutorial mode
      }
    });
  }

  // Return tutorial content for the current step
  Widget _buildTutorialOverlay() {
    if (!_isTutorialMode || _questions.isEmpty) return const SizedBox.shrink();

    final question = _questions[_currentQuestionIndex];
    final screenSize = MediaQuery.of(context).size;

    // Determine tutorial content based on step and question type
    String title = '';
    String content = '';
    Offset targetPosition = const Offset(0.5, 0.5);
    bool arrowDown = true;
    bool highlightWidget = false;

    switch (question.questionType) {
      case QuestionType.directIdentification:
        // Tutorial for direct identification
        switch (_tutorialStep) {
          case 0:
            title = 'Selamat Datang di Number Line!';
            content =
                'Pada permainan ini, kamu akan belajar menempatkan angka pada garis bilangan.';
            targetPosition = Offset(0.5, 0.3);
            arrowDown = true;
            break;
          case 1:
            title = 'Perhatikan Pertanyaan';
            content =
                'Baca pertanyaan dengan teliti. Kamu perlu menempatkan marker pada posisi angka yang benar.';
            targetPosition = Offset(0.5, 0.2);
            arrowDown = true;
            highlightWidget = true;
            break;
          case 2:
            title = 'Geser Marker';
            content =
                'Geser segitiga merah muda untuk menandai jawaban. Kedua segitiga harus ditempatkan pada posisi yang sama.';
            targetPosition = Offset(0.5, 0.6);
            arrowDown = false;
            highlightWidget = true;
            break;
          case 3:
            title = 'Periksa Jawaban';
            content =
                'Setelah yakin dengan jawaban, tekan tombol "Check Answer" untuk memeriksa jawaban.';
            targetPosition = Offset(0.5, 0.85);
            arrowDown = false;
            highlightWidget = true;
            break;
        }
        break;

      case QuestionType.addition:
        // Tutorial for addition
        switch (_tutorialStep) {
          case 0:
            title = 'Soal Penjumlahan';
            content =
                'Pada soal penjumlahan, kamu akan menggunakan garis bilangan untuk menunjukkan hasil penjumlahan.';
            targetPosition = Offset(0.5, 0.25);
            arrowDown = true;
            break;
          case 1:
            title = 'Bilangan Pertama';
            content =
                'Segitiga bawah sudah ditempatkan pada bilangan pertama dalam soal penjumlahan.';
            targetPosition = Offset(0.3, 0.5);
            arrowDown = false;
            highlightWidget = true;
            break;
          case 2:
            title = 'Temukan Hasil Penjumlahan';
            content =
                'Geser segitiga atas ke posisi yang menunjukkan hasil penjumlahan kedua bilangan tersebut.';
            targetPosition = Offset(0.7, 0.6);
            arrowDown = false;
            highlightWidget = true;
            break;
          case 3:
            title = 'Periksa Jawaban';
            content =
                'Setelah segitiga atas ditempatkan pada hasil penjumlahan, tekan tombol "Check Answer".';
            targetPosition = Offset(0.5, 0.85);
            arrowDown = false;
            highlightWidget = true;
            break;
        }
        break;

      // Add cases for other question types if needed

      default:
        // Default tutorial
        switch (_tutorialStep) {
          case 0:
            title = 'Selamat Datang di Number Line!';
            content =
                'Pada permainan ini, kamu akan belajar menempatkan angka pada garis bilangan.';
            targetPosition = Offset(0.5, 0.3);
            arrowDown = true;
            break;
          case 1:
            title = 'Zoom Slider';
            content =
                'Gunakan slider atas dengan kotak oranye untuk memperbesar bagian tertentu dari garis bilangan.';
            targetPosition = Offset(0.5, 0.2);
            arrowDown = true;
            highlightWidget = true;
            break;
          case 2:
            title = 'Segitiga Penanda';
            content =
                'Geser segitiga merah muda untuk menandai jawaban sesuai dengan yang diminta.';
            targetPosition = Offset(0.5, 0.6);
            arrowDown = false;
            highlightWidget = true;
            break;
          case 3:
            title = 'Periksa Jawaban';
            content =
                'Setelah yakin dengan jawaban, tekan tombol "Check Answer" untuk memeriksa jawaban.';
            targetPosition = Offset(0.5, 0.85);
            arrowDown = false;
            highlightWidget = true;
            break;
        }
    }

    // Build the tutorial overlay
    return Stack(
      children: [
        // Semi-transparent background
        Positioned.fill(
          child: GestureDetector(
            onTap: _advanceTutorial,
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),

        // Target position highlight
        if (highlightWidget)
          Positioned(
            left: targetPosition.dx * screenSize.width - 40.w,
            top: targetPosition.dy * screenSize.height - 40.h,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3.w,
                ),
              ),
            ),
          ),

        // Tutorial message box
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: arrowDown ? 120.h : 20.h,
          top: !arrowDown ? 120.h : null,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  content,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: _advanceTutorial,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.h, horizontal: 24.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Selanjutnya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Arrow pointing to target
        if (arrowDown)
          Positioned(
            left: targetPosition.dx * screenSize.width - 10.w,
            bottom: (1 - targetPosition.dy) * screenSize.height,
            child: CustomPaint(
              size: Size(20.w, 30.h),
              painter: ArrowPainter(isDown: true),
            ),
          )
        else
          Positioned(
            left: targetPosition.dx * screenSize.width - 10.w,
            top: targetPosition.dy * screenSize.height,
            child: CustomPaint(
              size: Size(20.w, 30.h),
              painter: ArrowPainter(isDown: false),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context, 1.0);

    if (!(_questions.isNotEmpty)) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get current question
    final currentQuestion = _questions[_currentQuestionIndex];

    // Calculate the width of the content area
    final contentWidth = MediaQuery.of(context).size.width - 32.w;

    // Calculate the position of the zoom indicator in the zoomed-out view
    final zoomPosition = _calculateZoomViewPosition(_topSliderPosition);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FF), // Light blue background
      body: SafeArea(
        child: Stack(
          children: [
            // Main game content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFA1C0F2),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: CardColors.blue.shadow,
                    width: 2.w,
                  ),
                ),
                child: Column(
                  children: [
                    // Main game content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Question text
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 16.h, horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: AppColors.questionBackground,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Text(
                                currentQuestion.question,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.instructionText,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            SizedBox(height: 12.h),
                            // Outer container with border and shadow
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4C77B9),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: const Color(
                                      0xFF285498), // Darker blue border
                                  width: 2.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(3, 3),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(10.w),
                              child: Column(
                                children: [
                                  // Display number with darker blue background for GCF questions
                                  if (currentQuestion.questionType ==
                                          QuestionType.gcf &&
                                      currentQuestion.operand1 != null)
                                    Container(
                                      width: double.infinity,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14.h),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                            0xFF285498), // Darker blue background
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        currentQuestion.operand1.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.numberPink,
                                          fontSize: 40.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                  SizedBox(height: 12.h),
                                  // Wrapping the specified section in a container with the requested properties
                                  Container(
                                    padding: EdgeInsets.only(
                                        top: 5.h,
                                        bottom: 20.h,
                                        left: 0,
                                        right: 0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF285498),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Column(
                                      children: [
                                        // Slider 1 - Top slider with orange rectangle
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 5.h, horizontal: 8.w),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 1.h, horizontal: 6.w),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                                0xFF093881), // Darker blue background
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                          child: SizedBox(
                                            height: 35.h,
                                            child: Stack(
                                              children: [
                                                // Base line
                                                Positioned(
                                                  left: 0,
                                                  right: 0,
                                                  top: 20.h,
                                                  child: Container(
                                                    height: 2.h,
                                                    color: Colors.white,
                                                  ),
                                                ),

                                                // 5 evenly distributed tick marks with labels above them
                                                ...List.generate(5, (index) {
                                                  final position = index / 4;
                                                  // Use the overall range from level for top slider
                                                  final value = _level
                                                          .minValue +
                                                      ((_level.maxValue -
                                                              _level.minValue) *
                                                          position);

                                                  return Stack(
                                                    children: [
                                                      // Tick mark
                                                      Positioned(
                                                        left: position *
                                                            (contentWidth -
                                                                20.w),
                                                        top: 16.h,
                                                        child: Container(
                                                          width: 2.w,
                                                          height: 8.h,
                                                          color: AppColors
                                                              .numberYellow,
                                                        ),
                                                      ),

                                                      // Number label directly above each tick mark
                                                      Positioned(
                                                        left: position *
                                                                (contentWidth -
                                                                    20.w) -
                                                            15.w,
                                                        top: 5.h,
                                                        child: Text(
                                                          value
                                                              .toInt()
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .numberYellow,
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }),

                                                // Make the entire slider area draggable with dampened movement
                                                Positioned.fill(
                                                  child: GestureDetector(
                                                    onPanUpdate: (details) {
                                                      setState(() {
                                                        // Apply a dampening factor to make movement "heavier"
                                                        final dampFactor =
                                                            0.3; // Lower = heavier feel

                                                        // Current position in pixels
                                                        final currentPosInPixels =
                                                            _topSliderPosition *
                                                                (contentWidth -
                                                                    20.w);

                                                        // Apply dampened movement
                                                        final newPosInPixels =
                                                            currentPosInPixels +
                                                                (details.delta
                                                                        .dx *
                                                                    dampFactor);

                                                        // Convert back to 0-1 range and clamp
                                                        _topSliderPosition =
                                                            (newPosInPixels /
                                                                    (contentWidth -
                                                                        20.w))
                                                                .clamp(
                                                                    0.0, 1.0);

                                                        // Update the detail view range based on new position
                                                        _updateDetailViewRange();
                                                      });
                                                    },
                                                  ),
                                                ),

                                                // Zoom window indicator with heavier drag response
                                                Positioned(
                                                  left: _topSliderPosition *
                                                          (contentWidth -
                                                              20.w) -
                                                      45.w,
                                                  top: 2.h,
                                                  child: GestureDetector(
                                                    onTapDown: (_) {
                                                      setState(() {
                                                        _isTopSliderActive =
                                                            true;
                                                        _topSliderController
                                                            .forward();
                                                      });
                                                    },
                                                    onTapUp: (_) {
                                                      setState(() {
                                                        _isTopSliderActive =
                                                            false;
                                                        _topSliderController
                                                            .reverse();
                                                      });
                                                    },
                                                    onPanStart: (_) {
                                                      setState(() {
                                                        _isTopSliderActive =
                                                            true;
                                                        _topSliderController
                                                            .forward();
                                                      });
                                                    },
                                                    onPanUpdate: (details) {
                                                      setState(() {
                                                        // Apply dampening factor for heavier feel
                                                        final dampFactor = 0.3;

                                                        // Current position in pixels
                                                        final currentPosInPixels =
                                                            _topSliderPosition *
                                                                (contentWidth -
                                                                    20.w);

                                                        // Apply dampened movement
                                                        final newPosInPixels =
                                                            currentPosInPixels +
                                                                (details.delta
                                                                        .dx *
                                                                    dampFactor);

                                                        // Convert back to 0-1 range and clamp
                                                        _topSliderPosition =
                                                            (newPosInPixels /
                                                                    (contentWidth -
                                                                        20.w))
                                                                .clamp(
                                                                    0.0, 1.0);

                                                        // Update the detail view range based on new position
                                                        _updateDetailViewRange();
                                                      });
                                                    },
                                                    onPanEnd: (_) {
                                                      setState(() {
                                                        _isTopSliderActive =
                                                            false;
                                                        _topSliderController
                                                            .reverse();
                                                      });
                                                    },
                                                    child: AnimatedBuilder(
                                                      animation:
                                                          _topSliderAnimation,
                                                      builder:
                                                          (context, child) {
                                                        return Transform.scale(
                                                          scale:
                                                              _topSliderAnimation
                                                                  .value,
                                                          child: Container(
                                                            width: 90.w,
                                                            height: 31.h,
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .orange,
                                                                width: 3.w,
                                                              ),
                                                              color: Colors.blue
                                                                  .withOpacity(
                                                                      0.3),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.r),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10.h),

                                        // Main number line area (detailed view)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(
                                                0xFF0B429A), // Darker blue background
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16.h, horizontal: 12.w),
                                          child: Column(
                                            children: [
                                              // Labels at the top left and right (moved to be aligned with down triangle)
                                              SizedBox(
                                                height: 40.h,
                                                child: Stack(
                                                  children: [
                                                    // Left label - Now using value from top slider range
                                                    Positioned(
                                                      left: 0,
                                                      top: 8
                                                          .h, // Aligned with the triangle
                                                      child: Text(
                                                        _minValue
                                                            .toInt()
                                                            .toString(),
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .numberYellow,
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    // Right label - Now using value from top slider range
                                                    Positioned(
                                                      right: 0,
                                                      top: 8
                                                          .h, // Aligned with the triangle
                                                      child: Text(
                                                        _maxValue
                                                            .toInt()
                                                            .toString(),
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .numberYellow,
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    // Down triangle (no circle, just triangle)
                                                    Positioned(
                                                      left: _downSliderPosition *
                                                              (contentWidth -
                                                                  100.w) -
                                                          15.w,
                                                      bottom: 0,
                                                      child: GestureDetector(
                                                        onPanStart: (_) {
                                                          setState(() {
                                                            _isDownSliderActive =
                                                                true;
                                                            _downSliderController
                                                                .forward();
                                                            _selectedValue =
                                                                _getValueFromPosition(
                                                                    _downSliderPosition);
                                                          });
                                                        },
                                                        onPanUpdate: (details) {
                                                          setState(() {
                                                            _downSliderPosition = (_downSliderPosition *
                                                                            (contentWidth -
                                                                                100
                                                                                    .w) +
                                                                        details
                                                                            .delta
                                                                            .dx)
                                                                    .clamp(
                                                                        0.0,
                                                                        contentWidth -
                                                                            100
                                                                                .w) /
                                                                (contentWidth -
                                                                    100.w);
                                                            _selectedValue =
                                                                _getValueFromPosition(
                                                                    _downSliderPosition);
                                                          });
                                                        },
                                                        onPanEnd: (_) {
                                                          setState(() {
                                                            _isDownSliderActive =
                                                                false;
                                                            _downSliderController
                                                                .reverse();
                                                            _snapDownSliderToNearestTick();
                                                          });
                                                        },
                                                        child: AnimatedBuilder(
                                                            animation:
                                                                _downSliderAnimation,
                                                            builder: (context,
                                                                child) {
                                                              return Transform
                                                                  .scale(
                                                                scale:
                                                                    _downSliderAnimation
                                                                        .value,
                                                                child: ClipPath(
                                                                  clipper: TriangleClipper(
                                                                      isDown:
                                                                          true),
                                                                  child:
                                                                      Container(
                                                                    width: 30.w,
                                                                    height:
                                                                        30.h,
                                                                    color: _isCheckingAnswer
                                                                        ? (_isCorrect
                                                                            ? AppColors
                                                                                .correctFeedback
                                                                            : AppColors
                                                                                .incorrectFeedback)
                                                                        : AppColors
                                                                            .trianglePointer,
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(height: 2.h),

                                              // Center line with tick marks - INCREASED HEIGHT
                                              SizedBox(
                                                height: 30.h,
                                                child: Stack(
                                                  children: [
                                                    // Horizontal line
                                                    Positioned(
                                                      left: 0,
                                                      right: 0,
                                                      top: 14.h,
                                                      child: Container(
                                                        height: 2.h,
                                                        color: _isCheckingAnswer
                                                            ? (_isCorrect
                                                                ? AppColors
                                                                    .correctFeedback
                                                                    .withOpacity(
                                                                        0.7)
                                                                : AppColors
                                                                    .incorrectFeedback
                                                                    .withOpacity(
                                                                        0.7))
                                                            : Colors.white,
                                                      ),
                                                    ),

                                                    // Tick marks
                                                    ...List.generate(11,
                                                        (index) {
                                                      final position =
                                                          index / 10.0;
                                                      final value = _minValue +
                                                          ((_maxValue -
                                                                  _minValue) *
                                                              position);

                                                      // Determine if this tick is selected by either slider
                                                      final isDownTick =
                                                          (_findNearestTickPosition(
                                                                          _downSliderPosition) *
                                                                      10)
                                                                  .round() ==
                                                              index;
                                                      final isUpTick =
                                                          (_findNearestTickPosition(
                                                                          _upSliderPosition) *
                                                                      10)
                                                                  .round() ==
                                                              index;
                                                      final isSelected =
                                                          isDownTick ||
                                                              isUpTick;

                                                      return Positioned(
                                                        left: index *
                                                            (contentWidth -
                                                                100.w) /
                                                            10,
                                                        top: 9.h,
                                                        child: Container(
                                                          height: 12.h,
                                                          width: 2.w,
                                                          color: _isCheckingAnswer &&
                                                                  isSelected
                                                              ? (_isCorrect
                                                                  ? AppColors
                                                                      .correctFeedback
                                                                  : AppColors
                                                                      .incorrectFeedback)
                                                              : AppColors
                                                                  .numberYellow,
                                                        ),
                                                      );
                                                    }),

                                                    // Optional tick labels for numbers
                                                    ...List.generate(11,
                                                        (index) {
                                                      if (index % 2 == 0) {
                                                        // Show every other number to avoid crowding
                                                        final position =
                                                            index / 10.0;
                                                        final value = _minValue +
                                                            ((_maxValue -
                                                                    _minValue) *
                                                                position);

                                                        return Positioned(
                                                          left: (index *
                                                                  (contentWidth -
                                                                      100.w) /
                                                                  10) -
                                                              10.w,
                                                          top: 24.h,
                                                          child: Text(
                                                            value
                                                                .toInt()
                                                                .toString(),
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .numberYellow,
                                                              fontSize: 10.sp,
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        return const SizedBox
                                                            .shrink();
                                                      }
                                                    }),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(height: 8.h),

                                              // Up triangle (no circle, just triangle) with shadow
                                              SizedBox(
                                                height: 40.h,
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    // Shadow for the up triangle
                                                    Positioned(
                                                      left: (_upSliderPosition *
                                                              (contentWidth -
                                                                  100.w)) -
                                                          3.w -
                                                          15.w,
                                                      top: 3.h,
                                                      child: ClipPath(
                                                        clipper:
                                                            TriangleClipper(
                                                                isDown: false),
                                                        child: Container(
                                                          width: 30.w,
                                                          height: 30.h,
                                                          color: Colors.black
                                                              .withOpacity(0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    // Up triangle
                                                    Positioned(
                                                      left: _upSliderPosition *
                                                              (contentWidth -
                                                                  100.w) -
                                                          15.w,
                                                      top: 0,
                                                      child: GestureDetector(
                                                        onPanStart: (_) {
                                                          setState(() {
                                                            _isUpSliderActive =
                                                                true;
                                                            _upSliderController
                                                                .forward();
                                                            _selectedValue =
                                                                _getValueFromPosition(
                                                                    _upSliderPosition);
                                                          });
                                                        },
                                                        onPanUpdate: (details) {
                                                          setState(() {
                                                            _upSliderPosition = (_upSliderPosition *
                                                                            (contentWidth -
                                                                                100
                                                                                    .w) +
                                                                        details
                                                                            .delta
                                                                            .dx)
                                                                    .clamp(
                                                                        0.0,
                                                                        contentWidth -
                                                                            100
                                                                                .w) /
                                                                (contentWidth -
                                                                    100.w);
                                                            _selectedValue =
                                                                _getValueFromPosition(
                                                                    _upSliderPosition);
                                                          });
                                                        },
                                                        onPanEnd: (_) {
                                                          setState(() {
                                                            _isUpSliderActive =
                                                                false;
                                                            _upSliderController
                                                                .reverse();
                                                            _snapUpSliderToNearestTick();
                                                          });
                                                        },
                                                        child: AnimatedBuilder(
                                                            animation:
                                                                _upSliderAnimation,
                                                            builder: (context,
                                                                child) {
                                                              return Transform
                                                                  .scale(
                                                                scale:
                                                                    _upSliderAnimation
                                                                        .value,
                                                                child: ClipPath(
                                                                  clipper: TriangleClipper(
                                                                      isDown:
                                                                          false),
                                                                  child:
                                                                      Container(
                                                                    width: 30.w,
                                                                    height:
                                                                        30.h,
                                                                    color: _isCheckingAnswer
                                                                        ? (_isCorrect
                                                                            ? AppColors
                                                                                .correctFeedback
                                                                            : AppColors
                                                                                .incorrectFeedback)
                                                                        : AppColors
                                                                            .trianglePointer,
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                      ),
                                                    ),

                                                    // Display selected value when dragging
                                                    if (_isDownSliderActive ||
                                                        _isUpSliderActive)
                                                      Positioned(
                                                        left: (_isDownSliderActive
                                                                    ? _downSliderPosition
                                                                    : _upSliderPosition) *
                                                                (contentWidth -
                                                                    100.w) -
                                                            20.w,
                                                        top:
                                                            (_isDownSliderActive
                                                                ? -30.h
                                                                : 35.h),
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 8.w,
                                                            vertical: 4.h,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColors
                                                                .numberPink,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.r),
                                                          ),
                                                          child: Text(
                                                            _selectedValue
                                                                    ?.toString() ??
                                                                '',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 14.h),
                                      ],
                                    ),
                                  ), // Check answer button at the center bottom
                                  SizedBox(height: 30.h),
                                  Center(
                                    child: Container(
                                      width: 200.w,
                                      height: 56.h,
                                      decoration: BoxDecoration(
                                        color: _isCheckingAnswer
                                            ? (_isCorrect
                                                ? AppColors.correctFeedback
                                                : AppColors.incorrectFeedback)
                                            : const Color(0xFF83E6B8),
                                        borderRadius:
                                            BorderRadius.circular(28.r),
                                        border: Border.all(
                                          color: _isCheckingAnswer
                                              ? (_isCorrect
                                                  ? const Color(0xFF66CC66)
                                                  : const Color(0xFFCC3333))
                                              : const Color(0xFF59B94D),
                                          width: 2.w,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: TextButton(
                                        onPressed: !_isCheckingAnswer
                                            ? (_isTutorialMode
                                                ? _advanceTutorial
                                                : _checkAnswer)
                                            : null,
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(28.r),
                                          ),
                                        ),
                                        child: Text(
                                          _isTutorialMode
                                              ? 'Next'
                                              : (_isCheckingAnswer
                                                  ? (_isCorrect
                                                      ? 'Correct!'
                                                      : 'Try Again')
                                                  : 'Check Answer'),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: _isCheckingAnswer
                                                ? Colors.white
                                                : const Color(0xFF59B94D),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Feedback area (shows when checking answer)
                            if (_isCheckingAnswer)
                              Container(
                                margin: EdgeInsets.only(top: 6.h),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: _isCorrect
                                      ? AppColors.correctFeedback
                                      : AppColors.incorrectFeedback,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  _isCorrect ? 'Correct!' : 'Not quite right',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tutorial overlay if in tutorial mode
            if (_isTutorialMode) _buildTutorialOverlay(),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for triangle shape
class TriangleClipper extends CustomClipper<Path> {
  final bool isDown;

  TriangleClipper({required this.isDown});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (isDown) {
      // Triangle pointing down
      path.moveTo(size.width / 2, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else {
      // Triangle pointing up
      path.moveTo(size.width / 2, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Custom painter for arrow in tutorial
class ArrowPainter extends CustomPainter {
  final bool isDown;

  ArrowPainter({required this.isDown});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isDown) {
      // Arrow pointing down
      path.moveTo(size.width / 2, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else {
      // Arrow pointing up
      path.moveTo(size.width / 2, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
