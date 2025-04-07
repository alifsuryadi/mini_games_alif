// Modified game_page.dart with dynamic number range based on slider position

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

    // Calculate the zoom window center value (in the number range)
    double zoomedValue = _minValue + ((_maxValue - _minValue) * zoomPosition);

    // Calculate the position of this value in the overall range
    return (zoomedValue - _minOverallValue) / totalRange;
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
                        // Outer container with border and shadow
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
                              // Wrapping the specified section in a container with the requested properties
                              Container(
                                padding: EdgeInsets.only(
                                    top: 5.h, bottom: 20.h, left: 0, right: 0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF285498),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                  children: [
                                    // Slider 1
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
                                                      value.toInt().toString(),
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
                                                            (details.delta.dx *
                                                                dampFactor);

                                                    // Convert back to 0-1 range and clamp
                                                    _topSliderPosition =
                                                        (newPosInPixels /
                                                                (contentWidth -
                                                                    20.w))
                                                            .clamp(0.0, 1.0);

                                                    // Update the detail view range based on new position
                                                    _updateDetailViewRange();
                                                  });
                                                },
                                              ),
                                            ),

                                            // Zoom window indicator with heavier drag response
                                            Positioned(
                                              left: _topSliderPosition *
                                                      (contentWidth - 20.w) -
                                                  45.w,
                                              top: 2.h,
                                              child: GestureDetector(
                                                onTapDown: (_) {
                                                  setState(() {
                                                    _isTopSliderActive = true;
                                                    _topSliderController
                                                        .forward();
                                                  });
                                                },
                                                onTapUp: (_) {
                                                  setState(() {
                                                    _isTopSliderActive = false;
                                                    _topSliderController
                                                        .reverse();
                                                  });
                                                },
                                                onPanStart: (_) {
                                                  setState(() {
                                                    _isTopSliderActive = true;
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
                                                            (details.delta.dx *
                                                                dampFactor);

                                                    // Convert back to 0-1 range and clamp
                                                    _topSliderPosition =
                                                        (newPosInPixels /
                                                                (contentWidth -
                                                                    20.w))
                                                            .clamp(0.0, 1.0);

                                                    // Update the detail view range based on new position
                                                    _updateDetailViewRange();
                                                  });
                                                },
                                                onPanEnd: (_) {
                                                  setState(() {
                                                    _isTopSliderActive = false;
                                                    _topSliderController
                                                        .reverse();
                                                  });
                                                },
                                                child: AnimatedBuilder(
                                                  animation:
                                                      _topSliderAnimation,
                                                  builder: (context, child) {
                                                    return Transform.scale(
                                                      scale: _topSliderAnimation
                                                          .value,
                                                      child: Container(
                                                        width: 90.w,
                                                        height: 31.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color:
                                                                Colors.orange,
                                                            width: 3.w,
                                                          ),
                                                          color: Colors.blue
                                                              .withOpacity(0.3),
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
                                                // Left label
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
                                                // Right label
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
                                                        _isDownSliderActive =
                                                            false;
                                                        _downSliderController
                                                            .reverse();
                                                      });
                                                    },
                                                    child: AnimatedBuilder(
                                                        animation:
                                                            _downSliderAnimation,
                                                        builder:
                                                            (context, child) {
                                                          return Transform
                                                              .scale(
                                                            scale:
                                                                _downSliderAnimation
                                                                    .value,
                                                            child: ClipPath(
                                                              clipper:
                                                                  TriangleClipper(
                                                                      isDown:
                                                                          true),
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
                                                    color: Colors.white,
                                                  ),
                                                ),

                                                // Tick marks
                                                ...List.generate(11, (index) {
                                                  return Positioned(
                                                    left: index *
                                                        (contentWidth - 100.w) /
                                                        10,
                                                    top: 9.h,
                                                    child: Container(
                                                      height: 12.h,
                                                      width: 2.w,
                                                      color: AppColors
                                                          .numberYellow,
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
                                                          (contentWidth -
                                                              100.w)) -
                                                      3.w -
                                                      15.w,
                                                  top: 3.h,
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
                                                        _isUpSliderActive =
                                                            false;
                                                        _upSliderController
                                                            .reverse();
                                                      });
                                                    },
                                                    child: AnimatedBuilder(
                                                        animation:
                                                            _upSliderAnimation,
                                                        builder:
                                                            (context, child) {
                                                          return Transform
                                                              .scale(
                                                            scale:
                                                                _upSliderAnimation
                                                                    .value,
                                                            child: ClipPath(
                                                              clipper:
                                                                  TriangleClipper(
                                                                      isDown:
                                                                          false),
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
                                    color: const Color(0xFF83E6B8),
                                    borderRadius: BorderRadius.circular(28.r),
                                    border: Border.all(
                                      color: const Color(0xFF59B94D),
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
                                        color: const Color(0xFF59B94D),
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
