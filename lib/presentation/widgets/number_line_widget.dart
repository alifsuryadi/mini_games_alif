import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_games_alif/core/styles/app_colors.dart';

enum SliderDirection { up, down, both }

class NumberLineWidget extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int step;
  final Function(int) onValueSelected;
  final Function(double)? onZoomPositionChanged;
  final double width;
  final double height;
  final bool showMarkers;
  final int? selectedValue;
  final SliderDirection direction;
  final bool isZoomed;
  final double? initialPosition;
  final bool showZoomIndicator;

  const NumberLineWidget({
    Key? key,
    required this.minValue,
    required this.maxValue,
    this.step = 1,
    required this.onValueSelected,
    this.onZoomPositionChanged,
    this.width = double.infinity,
    this.height = 80,
    this.showMarkers = true,
    this.selectedValue,
    this.direction = SliderDirection.down,
    this.isZoomed = false,
    this.initialPosition,
    this.showZoomIndicator = false,
  }) : super(key: key);

  @override
  State<NumberLineWidget> createState() => _NumberLineWidgetState();
}

class _NumberLineWidgetState extends State<NumberLineWidget>
    with SingleTickerProviderStateMixin {
  double _markerPosition = 0.5;
  double _dragPosition = 0.5;
  bool _isDragging = false;
  int? _hoveredValue;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    if (widget.initialPosition != null) {
      _markerPosition = widget.initialPosition!;
      _dragPosition = widget.initialPosition!;
    } else if (widget.selectedValue != null) {
      final values = _generateValues();
      final index = values.indexOf(widget.selectedValue!);
      if (index != -1) {
        _markerPosition = index / (values.length - 1);
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  List<int> _generateValues() {
    List<int> values = [];
    for (int i = widget.minValue; i <= widget.maxValue; i += widget.step) {
      values.add(i);
    }
    return values;
  }

  int _valueAtPosition(double position) {
    final values = _generateValues();
    final index = (position * (values.length - 1)).round();
    return values[index.clamp(0, values.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    final values = _generateValues();
    final lineColor = widget.isZoomed
        ? AppColors.numberLineBlue
        : AppColors.numberLineBlue.withOpacity(0.7);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Main line
          Positioned(
            left: 0,
            right: 0,
            top: widget.height * 0.5,
            child: Container(
              height: 3.h,
              color: lineColor,
            ),
          ),

          // Tick marks
          if (widget.showMarkers)
            ...List.generate(values.length, (index) {
              final position = index / (values.length - 1);
              return Positioned(
                left: position * widget.width,
                top: widget.height * 0.5 - 6.h,
                child: Container(
                  height: 12.h,
                  width: 2.w,
                  color: AppColors.numberYellow,
                ),
              );
            }),

          // Number labels
          if (widget.showMarkers)
            ...List.generate(values.length, (index) {
              final position = index / (values.length - 1);
              final showLabel =
                  index == 0 || index == values.length - 1 || index % 5 == 0;

              if (showLabel) {
                return Positioned(
                  left: position * widget.width - 15.w,
                  top: widget.direction == SliderDirection.up
                      ? widget.height * 0.5 - 24.h
                      : widget.height * 0.5 + 8.h,
                  child: SizedBox(
                    width: 30.w,
                    child: Text(
                      values[index].toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.numberYellow,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),

          // Zoom indicator box
          if (widget.isZoomed && widget.showZoomIndicator)
            Positioned(
              left: (_dragPosition * 0.8 + 0.1) * widget.width - 40.w,
              top: widget.height * 0.5 - 10.h,
              child: Container(
                width: 80.w,
                height: 20.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.orange,
                    width: 2.w,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),

          // Draggable marker (down direction)
          if (widget.direction != SliderDirection.up)
            Positioned(
              left: _isDragging
                  ? _dragPosition * widget.width - 15.w
                  : _markerPosition * widget.width - 15.w,
              top: widget.height * 0.5 - 35.h,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _isDragging = true;
                    _dragPosition = _markerPosition;
                    _scaleController.forward();
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _dragPosition =
                        ((details.localPosition.dx + 15.w) / widget.width)
                            .clamp(0.0, 1.0);

                    // Calculate nearest value
                    _hoveredValue = _valueAtPosition(_dragPosition);

                    if (widget.onZoomPositionChanged != null &&
                        widget.isZoomed) {
                      widget.onZoomPositionChanged!(_dragPosition);
                    }
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _isDragging = false;
                    _scaleController.reverse();

                    // Snap to nearest tick
                    final nearestIndex =
                        (_dragPosition * (values.length - 1)).round();
                    _markerPosition = nearestIndex / (values.length - 1);

                    // Notify parent of selection
                    if (nearestIndex >= 0 && nearestIndex < values.length) {
                      widget.onValueSelected(values[nearestIndex]);
                    }

                    _hoveredValue = null;
                  });
                },
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: const BoxDecoration(
                      color: AppColors.trianglePointer,
                      shape: BoxShape.circle,
                    ),
                    child: Transform.rotate(
                      angle: 3.14159, // 180 degrees (pointing down)
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Upward marker (up direction)
          if (widget.direction == SliderDirection.up ||
              widget.direction == SliderDirection.both)
            Positioned(
              left: _isDragging
                  ? _dragPosition * widget.width - 15.w
                  : _markerPosition * widget.width - 15.w,
              top: widget.height * 0.5 + 5.h,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _isDragging = true;
                    _dragPosition = _markerPosition;
                    _scaleController.forward();
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _dragPosition =
                        ((details.localPosition.dx + 15.w) / widget.width)
                            .clamp(0.0, 1.0);

                    // Calculate nearest value
                    _hoveredValue = _valueAtPosition(_dragPosition);

                    if (widget.onZoomPositionChanged != null &&
                        widget.isZoomed) {
                      widget.onZoomPositionChanged!(_dragPosition);
                    }
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _isDragging = false;
                    _scaleController.reverse();

                    // Snap to nearest tick
                    final nearestIndex =
                        (_dragPosition * (values.length - 1)).round();
                    _markerPosition = nearestIndex / (values.length - 1);

                    // Notify parent of selection
                    if (nearestIndex >= 0 && nearestIndex < values.length) {
                      widget.onValueSelected(values[nearestIndex]);
                    }

                    _hoveredValue = null;
                  });
                },
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: const BoxDecoration(
                      color: AppColors.trianglePointer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ),

          // Selected value label (shows when dragging)
          if (_isDragging && _hoveredValue != null)
            Positioned(
              left: _dragPosition * widget.width - 25.w,
              top: widget.direction == SliderDirection.up
                  ? widget.height * 0.1
                  : widget.direction == SliderDirection.down
                      ? widget.height * 0.7
                      : widget.height * 0.5 - 15.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.trianglePointer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _hoveredValue.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Highlight current position on zoomed view
          if (widget.isZoomed && widget.selectedValue != null && !_isDragging)
            Positioned(
              left: _markerPosition * widget.width - 10.w,
              top: widget.height * 0.5 - 10.h,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
