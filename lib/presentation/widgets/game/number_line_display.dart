import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_games_alif/core/styles/app_colors.dart';
import 'package:mini_games_alif/domain/models/question_model.dart';
import 'package:mini_games_alif/presentation/controllers/game_controller.dart';
import 'package:provider/provider.dart';

class NumberLineDisplay extends StatefulWidget {
  final QuestionModel question;
  final bool isCheckingAnswer;
  final bool isCorrect;

  const NumberLineDisplay({
    Key? key,
    required this.question,
    required this.isCheckingAnswer,
    required this.isCorrect,
  }) : super(key: key);

  @override
  State<NumberLineDisplay> createState() => _NumberLineDisplayState();
}

class _NumberLineDisplayState extends State<NumberLineDisplay>
    with TickerProviderStateMixin {
  // Animation controllers for hover effects
  late AnimationController _topSliderController;
  late AnimationController _downSliderController;
  late AnimationController _upSliderController;
  late Animation<double> _topSliderAnimation;
  late Animation<double> _downSliderAnimation;
  late Animation<double> _upSliderAnimation;

  // Animation controllers for slider snapping animation
  late AnimationController _downSliderSnapController;
  late AnimationController _upSliderSnapController;
  late Animation<double> _downSliderSnapAnimation;
  late Animation<double> _upSliderSnapAnimation;

  // Target positions for animated snapping
  double _downSliderTargetPosition = 0.5;
  double _upSliderTargetPosition = 0.5;

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

  // Snap animation update listeners
  void _updateDownSliderSnap() {
    if (!_downSliderSnapController.isAnimating) return;

    final controller = Provider.of<GameController>(context, listen: false);
    double startPosition = controller.downSliderPosition;
    double endPosition = _downSliderTargetPosition;
    double newPosition = startPosition +
        (_downSliderSnapAnimation.value * (endPosition - startPosition));

    controller.setDownSliderPosition(newPosition);
  }

  void _updateUpSliderSnap() {
    if (!_upSliderSnapController.isAnimating) return;

    final controller = Provider.of<GameController>(context, listen: false);
    double startPosition = controller.upSliderPosition;
    double endPosition = _upSliderTargetPosition;
    double newPosition = startPosition +
        (_upSliderSnapAnimation.value * (endPosition - startPosition));

    controller.setUpSliderPosition(newPosition);
  }

  // Animate slider to snap to nearest tick mark
  void _snapDownSliderToNearestTick(GameController controller) {
    _downSliderTargetPosition =
        controller.findNearestTickPosition(controller.downSliderPosition);

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
  void _snapUpSliderToNearestTick(GameController controller) {
    _upSliderTargetPosition =
        controller.findNearestTickPosition(controller.upSliderPosition);

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
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);
    final contentWidth = MediaQuery.of(context).size.width - 32.w;

    // Show color feedback on the number line when checking answer
    Color numberLineColor = AppColors.numberLineBlue;
    if (widget.isCheckingAnswer) {
      numberLineColor = widget.isCorrect
          ? AppColors.correctFeedback
          : AppColors.incorrectFeedback;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF285498),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Only show zoom slider if zoom mode is enabled
          if (controller.isZoomModeEnabled)
            Container(
              margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 8.w),
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 6.w),
              decoration: BoxDecoration(
                color: const Color(0xFF093881),
                borderRadius: BorderRadius.circular(8.r),
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

                    // Tick marks with labels
                    ...List.generate(5, (index) {
                      final position = index / 4;
                      final value = controller.level!.minValue +
                          (controller.level!.maxValue -
                                  controller.level!.minValue) *
                              position;

                      return Stack(
                        children: [
                          // Tick mark
                          Positioned(
                            left: position * (contentWidth - 20.w),
                            top: 16.h,
                            child: Container(
                              width: 2.w,
                              height: 8.h,
                              color: AppColors.numberYellow,
                            ),
                          ),

                          // Number label directly above each tick mark
                          Positioned(
                            left: position * (contentWidth - 20.w) - 15.w,
                            top: 5.h,
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

                    // Make the entire slider area draggable with dampened movement
                    Positioned.fill(
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          // Calculate damped movement
                          final dampFactor = 0.3; // Lower = heavier feel
                          final currentPosInPixels =
                              controller.topSliderPosition *
                                  (contentWidth - 20.w);
                          final newPosInPixels = currentPosInPixels +
                              (details.delta.dx * dampFactor);

                          // Update position
                          controller.setTopSliderPosition(
                              (newPosInPixels / (contentWidth - 20.w))
                                  .clamp(0.0, 1.0));
                        },
                      ),
                    ),

                    // Zoom window indicator
                    Positioned(
                      left:
                          controller.topSliderPosition * (contentWidth - 20.w) -
                              45.w,
                      top: 2.h,
                      child: GestureDetector(
                        onTapDown: (_) {
                          controller.setTopSliderActive(true);
                          _topSliderController.forward();
                        },
                        onTapUp: (_) {
                          controller.setTopSliderActive(false);
                          _topSliderController.reverse();
                        },
                        onPanStart: (_) {
                          controller.setTopSliderActive(true);
                          _topSliderController.forward();
                        },
                        onPanUpdate: (details) {
                          // Apply dampening factor for heavier feel
                          final dampFactor = 0.3;
                          final currentPosInPixels =
                              controller.topSliderPosition *
                                  (contentWidth - 20.w);
                          final newPosInPixels = currentPosInPixels +
                              (details.delta.dx * dampFactor);

                          // Update position
                          controller.setTopSliderPosition(
                              (newPosInPixels / (contentWidth - 20.w))
                                  .clamp(0.0, 1.0));
                        },
                        onPanEnd: (_) {
                          controller.setTopSliderActive(false);
                          _topSliderController.reverse();
                        },
                        child: AnimatedBuilder(
                          animation: _topSliderAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _topSliderAnimation.value,
                              child: Container(
                                width: 90.w,
                                height: 31.h,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 3.w,
                                  ),
                                  color: Colors.blue.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10.r),
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
              color: const Color(0xFF0B429A),
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
            child: Column(
              children: [
                // Labels at the top left and right with down triangle
                SizedBox(
                  height: 40.h,
                  child: Stack(
                    children: [
                      // Left label
                      Positioned(
                        left: 0,
                        top: 8.h,
                        child: Text(
                          controller.minValue.toInt().toString(),
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
                        top: 8.h,
                        child: Text(
                          controller.maxValue.toInt().toString(),
                          style: TextStyle(
                            color: AppColors.numberYellow,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Down triangle (no circle, just triangle)
                      Positioned(
                        left: controller.downSliderPosition *
                                (contentWidth - 100.w) -
                            15.w,
                        bottom: 0,
                        child: GestureDetector(
                          onPanStart: (_) {
                            controller.setDownSliderActive(true);
                            _downSliderController.forward();
                          },
                          onPanUpdate: (details) {
                            final newPosition = (controller.downSliderPosition *
                                            (contentWidth - 100.w) +
                                        details.delta.dx)
                                    .clamp(0.0, contentWidth - 100.w) /
                                (contentWidth - 100.w);
                            controller.setDownSliderPosition(newPosition);
                          },
                          onPanEnd: (_) {
                            controller.setDownSliderActive(false);
                            _downSliderController.reverse();
                            _snapDownSliderToNearestTick(controller);
                          },
                          child: AnimatedBuilder(
                              animation: _downSliderAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _downSliderAnimation.value,
                                  child: ClipPath(
                                    clipper: TriangleClipper(isDown: true),
                                    child: Container(
                                      width: 30.w,
                                      height: 30.h,
                                      color: widget.isCheckingAnswer
                                          ? (widget.isCorrect
                                              ? AppColors.correctFeedback
                                              : AppColors.incorrectFeedback)
                                          : AppColors.trianglePointer,
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
                          color: numberLineColor,
                        ),
                      ),

                      // Tick marks
                      ...List.generate(11, (index) {
                        final position = index / 10.0;
                        final value = controller.minValue +
                            (controller.maxValue - controller.minValue) *
                                position;
                        final isSelected = widget.isCheckingAnswer &&
                            ((controller.findNearestTickPosition(
                                                controller.downSliderPosition) *
                                            10)
                                        .round() ==
                                    index ||
                                (controller.findNearestTickPosition(
                                                controller.upSliderPosition) *
                                            10)
                                        .round() ==
                                    index);

                        return Positioned(
                          left: index * (contentWidth - 100.w) / 10,
                          top: 9.h,
                          child: Container(
                            height: 12.h,
                            width: 2.w,
                            color: isSelected
                                ? (widget.isCorrect
                                    ? AppColors.correctFeedback
                                    : AppColors.incorrectFeedback)
                                : AppColors.numberYellow,
                          ),
                        );
                      }),

                      // Optional tick labels (for smaller number ranges)
                      if ((controller.maxValue - controller.minValue) <= 20)
                        ...List.generate(11, (index) {
                          final position = index / 10.0;
                          final value = controller.minValue +
                              (controller.maxValue - controller.minValue) *
                                  position;

                          // Only show every other label to avoid overcrowding
                          if (index % 2 == 0) {
                            return Positioned(
                              left:
                                  (index * (contentWidth - 100.w) / 10) - 10.w,
                              top: 24.h,
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: AppColors.numberYellow,
                                  fontSize: 10.sp,
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // Up triangle with shadow
                SizedBox(
                  height: 40.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Shadow for the up triangle
                      Positioned(
                        left: (controller.upSliderPosition *
                                (contentWidth - 100.w)) -
                            3.w -
                            15.w,
                        top: 3.h,
                        child: ClipPath(
                          clipper: TriangleClipper(isDown: false),
                          child: Container(
                            width: 30.w,
                            height: 30.h,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ),
                      // Up triangle
                      Positioned(
                        left: controller.upSliderPosition *
                                (contentWidth - 100.w) -
                            15.w,
                        top: 0,
                        child: GestureDetector(
                          onPanStart: (_) {
                            controller.setUpSliderActive(true);
                            _upSliderController.forward();
                          },
                          onPanUpdate: (details) {
                            final newPosition = (controller.upSliderPosition *
                                            (contentWidth - 100.w) +
                                        details.delta.dx)
                                    .clamp(0.0, contentWidth - 100.w) /
                                (contentWidth - 100.w);
                            controller.setUpSliderPosition(newPosition);
                          },
                          onPanEnd: (_) {
                            controller.setUpSliderActive(false);
                            _upSliderController.reverse();
                            _snapUpSliderToNearestTick(controller);
                          },
                          child: AnimatedBuilder(
                              animation: _upSliderAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _upSliderAnimation.value,
                                  child: ClipPath(
                                    clipper: TriangleClipper(isDown: false),
                                    child: Container(
                                      width: 30.w,
                                      height: 30.h,
                                      color: widget.isCheckingAnswer
                                          ? (widget.isCorrect
                                              ? AppColors.correctFeedback
                                              : AppColors.incorrectFeedback)
                                          : AppColors.trianglePointer,
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),

                      // Show value labels when dragging
                      if (controller.isDownSliderActive ||
                          controller.isUpSliderActive)
                        Positioned(
                          left: (controller.isDownSliderActive
                                      ? controller.downSliderPosition
                                      : controller.upSliderPosition) *
                                  (contentWidth - 100.w) -
                              20.w,
                          top: controller.isDownSliderActive ? -30.h : 35.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.numberPink,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              controller.selectedValue?.toString() ?? "",
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
              ],
            ),
          ),
        ],
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
