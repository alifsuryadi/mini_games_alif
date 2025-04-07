// This is the modified game_page.dart with the int to double conversion fix

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

  // Variables for the number line
  double _topSliderPosition = 0.5; // Temperature-like slider
  double _downSliderPosition = 0.5; // Down triangle slider
  double _upSliderPosition = 0.5; // Up triangle slider

  // State for active sliders
  bool _isTopSliderActive = false;
  bool _isDownSliderActive = false;
  bool _isUpSliderActive = false;

  // Number line values - explicitly define these as double to avoid type errors
  double _minValue = 1650.0;
  double _maxValue = 1660.0;

  // Zoom range (the overall range for the zoomed-out view) - converted to double
  double _minOverallValue = 1600.0;
  double _maxOverallValue = 1700.0;

  // Animation controllers for hover effects
  late AnimationController _topSliderController;
  late AnimationController _downSliderController;
  late AnimationController _upSliderController;
  late Animation<double> _topSliderAnimation;
  late Animation<double> _downSliderAnimation;
  late Animation<double> _upSliderAnimation;

// Update the animation controller speed in initState()
  @override
  void initState() {
    super.initState();

    // Initialize animation controllers with faster duration (100ms instead of 200ms)
    _topSliderController = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 100), // Reduced from 200ms to 100ms
    );
    _downSliderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _upSliderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Define animations
    _topSliderAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _topSliderController, curve: Curves.easeOut));
    _downSliderAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _downSliderController, curve: Curves.easeOut));
    _upSliderAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _upSliderController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  @override
  void dispose() {
    _topSliderController.dispose();
    _downSliderController.dispose();
    _upSliderController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final levelId = args != null ? args['levelId'] as int : 1;

    _level = _repository.getLevelById(levelId)!;
    _questions = _repository.getQuestionsForLevel(levelId, count: 5);

    setState(() {});
  }

  int _getValueFromPosition(double position) {
    // Use .toDouble() to ensure proper calculation, then round to int
    return (_minValue + ((_maxValue - _minValue) * position)).round();
  }

  // Calculate visible range for zoomed-out view
  double _calculateZoomViewPosition(double zoomPosition) {
    // Convert the zoom position to a value in the overall range
    double totalRange = _maxOverallValue - _minOverallValue;
    double zoomWidth = (_maxValue - _minValue) / totalRange;

    // Calculate the position of the zoom window within the overall range
    return (_minValue - _minOverallValue) / totalRange +
        (zoomPosition * zoomWidth);
  }

  void _checkAnswer() {
    if (_selectedValue == null) {
      // Use the position of a slider if no value is explicitly selected
      _selectedValue = _getValueFromPosition(_downSliderPosition);
    }

    // Calculate GCF (for this example using a fixed value)
    final correctAnswer =
        826; // In a real app: _numberLineUseCase.calculateHCF(1654, 826);

    setState(() {
      _isCheckingAnswer = true;
      _isCorrect = _selectedValue == correctAnswer;

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

    // Calculate the width of the content area
    final contentWidth = MediaQuery.of(context).size.width - 32.w;

    // Calculate the position of the zoom indicator in the zoomed-out view
    final zoomPosition = _calculateZoomViewPosition(_topSliderPosition);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FF), // Light blue background
      body: SafeArea(
        child: Padding(
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                            'What is the highest\nGreatest Common Factor\nbetween these 2 values:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.instructionText,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),
                        // Outer container with border and shadow - CHANGED COLOR FROM 0xFF4C77B9 to 0xFF285498
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C77B9),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color:
                                  const Color(0xFF285498), // Darker blue border
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
                              // Display number with darker blue background
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                decoration: BoxDecoration(
                                  color: const Color(
                                      0xFF285498), // Darker blue background
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  '1654',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.numberPink,
                                    fontSize: 40.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              SizedBox(height: 12.h),

// Updated Slider 1 container with exactly 5 tick marks, each with a number label
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 1.h, horizontal: 6.w),
                                decoration: BoxDecoration(
                                  color: const Color(
                                      0xFF285498), // Darker blue background
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: SizedBox(
                                  height: 40.h,
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
                                        // Calculate positions evenly across the width: 0, 0.25, 0.5, 0.75, 1.0
                                        final position = index / 4;
                                        // Calculate values for the 5 evenly spaced points
                                        final value = _minOverallValue +
                                            (_maxOverallValue -
                                                    _minOverallValue) *
                                                position;

                                        return Stack(
                                          children: [
                                            // Tick mark
                                            Positioned(
                                              left: position *
                                                  (contentWidth - 20.w),
                                              top: 16.h,
                                              child: Container(
                                                width: 2.w,
                                                height: 8.h,
                                                color: AppColors.numberYellow,
                                              ),
                                            ),

                                            // Number label directly above each tick mark
                                            Positioned(
                                              left: position *
                                                      (contentWidth - 20.w) -
                                                  15.w, // Center the label over the tick
                                              top: 2.h,
                                              child: Text(
                                                value.toInt().toString(),
                                                style: TextStyle(
                                                  color: AppColors.numberYellow,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),

                                      // Make the entire slider area draggable
                                      Positioned.fill(
                                        child: GestureDetector(
                                          onPanUpdate: (details) {
                                            setState(() {
                                              // Calculate new position based on horizontal drag
                                              final newPosition =
                                                  (_topSliderPosition *
                                                                  (contentWidth -
                                                                      140.w -
                                                                      36.w) +
                                                              details.delta.dx)
                                                          .clamp(
                                                              0.0,
                                                              contentWidth -
                                                                  140.w -
                                                                  36.w) /
                                                      (contentWidth -
                                                          140.w -
                                                          36.w);

                                              // Update slider position
                                              _topSliderPosition = newPosition;
                                            });
                                          },
                                        ),
                                      ),

                                      // Zoom window indicator - shows the visible part in main view
                                      // Enlarged orange border with translucent blue fill
                                      Positioned(
                                        left: zoomPosition *
                                                (contentWidth - 20.w) -
                                            45.w,
                                        top: 10.h,
                                        child: GestureDetector(
                                          onTapDown: (_) {
                                            setState(() {
                                              _isTopSliderActive = true;
                                              _topSliderController.forward();
                                            });
                                          },
                                          onTapUp: (_) {
                                            setState(() {
                                              _isTopSliderActive = false;
                                              _topSliderController.reverse();
                                            });
                                          },
                                          onPanStart: (_) {
                                            setState(() {
                                              _isTopSliderActive = true;
                                              _topSliderController.forward();
                                            });
                                          },
                                          onPanUpdate: (details) {
                                            setState(() {
                                              _topSliderPosition =
                                                  (_topSliderPosition *
                                                                  (contentWidth -
                                                                      140.w -
                                                                      36.w) +
                                                              details.delta.dx)
                                                          .clamp(
                                                              0.0,
                                                              contentWidth -
                                                                  140.w -
                                                                  36.w) /
                                                      (contentWidth -
                                                          140.w -
                                                          36.w);
                                            });
                                          },
                                          onPanEnd: (_) {
                                            setState(() {
                                              _isTopSliderActive = false;
                                              _topSliderController.reverse();
                                            });
                                          },
                                          child: AnimatedBuilder(
                                            animation: _topSliderAnimation,
                                            builder: (context, child) {
                                              return Transform.scale(
                                                scale:
                                                    _topSliderAnimation.value,
                                                child: Container(
                                                  width: 90.w,
                                                  height: 20.h,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.orange,
                                                      width: 3.w,
                                                    ),
                                                    color: Colors.blue.withOpacity(
                                                        0.3), // Translucent blue fill
                                                    borderRadius:
                                                        BorderRadius.circular(
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

                              SizedBox(height: 12.h),

                              // Main number line area (detailed view)
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(
                                      0xFF285498), // Darker blue background
                                  borderRadius: BorderRadius.circular(12.r),
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
                                          // Left label
                                          Positioned(
                                            left: 0,
                                            top: 8
                                                .h, // Aligned with the triangle
                                            child: Text(
                                              _minValue.toInt().toString(),
                                              style: TextStyle(
                                                color: AppColors.numberYellow,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          // Right label
                                          Positioned(
                                            right: 0,
                                            top: 8
                                                .h, // Aligned with the triangle
                                            child: Text(
                                              _maxValue.toInt().toString(),
                                              style: TextStyle(
                                                color: AppColors.numberYellow,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          // Down triangle (no circle, just triangle)
                                          Positioned(
                                            left: _downSliderPosition *
                                                (contentWidth - 100.w),
                                            top: 0,
                                            child: GestureDetector(
                                              onPanStart: (_) {
                                                setState(() {
                                                  _isDownSliderActive = true;
                                                  _downSliderController
                                                      .forward();
                                                  _selectedValue =
                                                      _getValueFromPosition(
                                                          _downSliderPosition);
                                                });
                                              },
                                              onPanUpdate: (details) {
                                                setState(() {
                                                  _downSliderPosition =
                                                      (_downSliderPosition *
                                                                      (contentWidth -
                                                                          100
                                                                              .w) +
                                                                  details
                                                                      .delta.dx)
                                                              .clamp(
                                                                  0.0,
                                                                  contentWidth -
                                                                      100.w) /
                                                          (contentWidth -
                                                              100.w);
                                                  _selectedValue =
                                                      _getValueFromPosition(
                                                          _downSliderPosition);
                                                });
                                              },
                                              onPanEnd: (_) {
                                                setState(() {
                                                  _isDownSliderActive = false;
                                                  _downSliderController
                                                      .reverse();
                                                });
                                              },
                                              child: AnimatedBuilder(
                                                  animation:
                                                      _downSliderAnimation,
                                                  builder: (context, child) {
                                                    return Transform.scale(
                                                      scale:
                                                          _downSliderAnimation
                                                              .value,
                                                      child: ClipPath(
                                                        clipper:
                                                            TriangleClipper(
                                                                isDown: true),
                                                        child: Container(
                                                          width: 30.w,
                                                          height: 30.h,
                                                          color: AppColors
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

                                    SizedBox(height: 8.h),

                                    // Center line with tick marks - INCREASED HEIGHT
                                    SizedBox(
                                      height: 30
                                          .h, // Increased from 20.h to 30.h for more space
                                      child: Stack(
                                        children: [
                                          // Horizontal line
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            top: 14
                                                .h, // Centered in the increased height
                                            child: Container(
                                              height: 2.h,
                                              color: Colors.white,
                                            ),
                                          ),

                                          // Tick marks
                                          ...List.generate(11, (index) {
                                            return Positioned(
                                              left: index *
                                                  (contentWidth - 100.w) /
                                                  10,
                                              top: 9
                                                  .h, // Adjusted for the new height
                                              child: Container(
                                                height: 12
                                                    .h, // Increased from 10.h to 12.h
                                                width: 2.w,
                                                color: AppColors.numberYellow,
                                              ),
                                            );
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
                                                    (contentWidth - 100.w)) -
                                                3.w, // Offset left for shadow
                                            top: 3.h, // Offset down for shadow
                                            child: ClipPath(
                                              clipper: TriangleClipper(
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
                                                (contentWidth - 100.w),
                                            top: 0,
                                            child: GestureDetector(
                                              onPanStart: (_) {
                                                setState(() {
                                                  _isUpSliderActive = true;
                                                  _upSliderController.forward();
                                                  _selectedValue =
                                                      _getValueFromPosition(
                                                          _upSliderPosition);
                                                });
                                              },
                                              onPanUpdate: (details) {
                                                setState(() {
                                                  _upSliderPosition =
                                                      (_upSliderPosition *
                                                                      (contentWidth -
                                                                          100
                                                                              .w) +
                                                                  details
                                                                      .delta.dx)
                                                              .clamp(
                                                                  0.0,
                                                                  contentWidth -
                                                                      100.w) /
                                                          (contentWidth -
                                                              100.w);
                                                  _selectedValue =
                                                      _getValueFromPosition(
                                                          _upSliderPosition);
                                                });
                                              },
                                              onPanEnd: (_) {
                                                setState(() {
                                                  _isUpSliderActive = false;
                                                  _upSliderController.reverse();
                                                });
                                              },
                                              child: AnimatedBuilder(
                                                  animation: _upSliderAnimation,
                                                  builder: (context, child) {
                                                    return Transform.scale(
                                                      scale: _upSliderAnimation
                                                          .value,
                                                      child: ClipPath(
                                                        clipper:
                                                            TriangleClipper(
                                                                isDown: false),
                                                        child: Container(
                                                          width: 30.w,
                                                          height: 30.h,
                                                          color: AppColors
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
                                  ],
                                ),
                              ),

                              // MOVED: Check answer button to the center of the bottom part of the card
                              SizedBox(height: 44.h),

                              // Check answer button at the center bottom
                              Center(
                                child: Container(
                                  width: 200
                                      .w, // Limiting width for center alignment
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFF83E6B8), // Changed from AppColors.checkAnswerButton to #83E6B8
                                    borderRadius: BorderRadius.circular(28.r),
                                    border: Border.all(
                                      color: const Color(
                                          0xFF59B94D), // Changed border color to #59B94D
                                      width: 2.w,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextButton(
                                    onPressed: !_isCheckingAnswer
                                        ? _checkAnswer
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
                                      'Check Answer',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(
                                            0xFF59B94D), // Changed text color to match border
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
                            margin: EdgeInsets.only(top: 16.h),
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
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // REMOVED: Check answer button from here as it's now inside the card content above
              ],
            ),
          ),
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
