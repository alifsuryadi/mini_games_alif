import 'package:flutter/material.dart';

class GCFNumberLine extends StatefulWidget {
  final int value1;
  final int value2;
  final int minRange;
  final int maxRange;
  final int rangeWidth;
  final Function(int) onAnswerSubmitted;

  const GCFNumberLine({
    super.key,
    required this.value1,
    required this.value2,
    required this.minRange,
    required this.maxRange,
    required this.rangeWidth,
    required this.onAnswerSubmitted,
  });

  @override
  State<GCFNumberLine> createState() => _GCFNumberLineState();
}

class _GCFNumberLineState extends State<GCFNumberLine> {
  // Positions for the three triangles/sliders
  double rangeSliderPosition = 0;
  double upperTrianglePosition = 0;
  double lowerTrianglePosition = 0;

  // Range and selected values
  late int minValue;
  late int maxValue;
  int? upperSelectedValue;
  int? lowerSelectedValue;

  @override
  void initState() {
    super.initState();
    // Initialize range to be around the first value
    minValue = (widget.value1 ~/ widget.rangeWidth) * widget.rangeWidth;
    maxValue = minValue + widget.rangeWidth;

    // Ensure range values are within allowed limits
    if (minValue < widget.minRange) minValue = widget.minRange;
    if (maxValue > widget.maxRange) maxValue = widget.maxRange;

    // Initialize triangle positions to middle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = context.size;
        if (size != null) {
          setState(() {
            upperTrianglePosition = size.width / 2;
            lowerTrianglePosition = size.width / 2;
          });
        }
      }
    });
  }

  // Calculate GCF of two numbers
  int calculateGCF(int a, int b) {
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF3F51B5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Question text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF5C6BC0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'What is the highest\nGreatest Common Factor\nbetween these 2 values:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Number display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3949AB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.value1}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFF4081),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // First number range slider
            buildRangeSlider(),
            const SizedBox(height: 16),

            // Upper and lower triangle number lines
            buildNumberLines(),

            const SizedBox(height: 32),

            // Check answer button
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF8BC34A),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextButton(
                onPressed: () {
                  if (upperSelectedValue != null &&
                      lowerSelectedValue != null) {
                    int gcf =
                        calculateGCF(upperSelectedValue!, lowerSelectedValue!);
                    widget.onAnswerSubmitted(gcf);
                  }
                },
                child: const Text(
                  'Check Answer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRangeSlider() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          // Slider background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF303F9F),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Slider track
          Positioned(
            left: 10,
            right: 10,
            top: 16,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Tick marks
          Positioned(
            left: 10,
            right: 10,
            top: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                5,
                (index) => Container(
                  width: 2,
                  height: 8,
                  color: Colors.white30,
                ),
              ),
            ),
          ),

          // Selected range indicator
          Positioned(
            left: 60,
            top: 10,
            child: Container(
              width: 60,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
            ),
          ),

          // Range labels
          Positioned(
            left: 10,
            bottom: 2,
            child: Text(
              '$minValue',
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 2,
            child: Text(
              '$maxValue',
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Draggable area for the range
          Positioned.fill(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  rangeSliderPosition = (rangeSliderPosition + details.delta.dx)
                      .clamp(0, MediaQuery.of(context).size.width - 100);

                  // Calculate the steps for range adjustment
                  final availableRange = widget.maxRange - widget.minRange;
                  final step = availableRange ~/
                      10; // Divide available range into 10 steps

                  // Update range values based on slider position
                  final progress = rangeSliderPosition /
                      (MediaQuery.of(context).size.width - 100);
                  final rangeDiff = widget.rangeWidth;

                  // Calculate new min value ensuring it stays within limits
                  final newMin = widget.minRange +
                      (progress * (availableRange - rangeDiff)).round();
                  minValue = newMin;
                  maxValue = minValue + rangeDiff;

                  // Ensure max value doesn't exceed the limit
                  if (maxValue > widget.maxRange) {
                    maxValue = widget.maxRange;
                    minValue = maxValue - rangeDiff;
                  }

                  // Reset selected values when range changes
                  upperSelectedValue = null;
                  lowerSelectedValue = null;
                });
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNumberLines() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF303F9F),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          // Upper triangle
          Positioned(
            top: 20,
            left: upperTrianglePosition,
            child: CustomPaint(
              size: const Size(20, 20),
              painter: TrianglePainter(const Color(0xFFFF4081),
                  isPointingDown: true),
            ),
          ),

          // Upper number line
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              height: 2,
              color: const Color(0xFF8BC34A),
            ),
          ),

          // Upper tick marks
          Positioned(
            top: 38,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                11,
                (index) => Container(
                  width: 2,
                  height: 6,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Lower triangle
          Positioned(
            bottom: 20,
            left: lowerTrianglePosition,
            child: CustomPaint(
              size: const Size(30, 30),
              painter: TrianglePainter(const Color(0xFFFF4081)),
            ),
          ),

          // Lower number line
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              height: 2,
              color: const Color(0xFF8BC34A),
            ),
          ),

          // Lower tick marks
          Positioned(
            bottom: 48,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                11,
                (index) => Container(
                  width: 2,
                  height: 6,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Gesture detector for upper triangle
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 60,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  final width = MediaQuery.of(context).size.width - 40;
                  upperTrianglePosition =
                      (upperTrianglePosition + details.delta.dx)
                          .clamp(20, width - 20);

                  // Calculate selected value
                  final percentage =
                      (upperTrianglePosition - 20) / (width - 40);
                  upperSelectedValue =
                      minValue + (percentage * (maxValue - minValue)).round();
                });
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Gesture detector for lower triangle
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  final width = MediaQuery.of(context).size.width - 40;
                  lowerTrianglePosition =
                      (lowerTrianglePosition + details.delta.dx)
                          .clamp(20, width - 20);

                  // Calculate selected value
                  final percentage =
                      (lowerTrianglePosition - 20) / (width - 40);
                  lowerSelectedValue =
                      minValue + (percentage * (maxValue - minValue)).round();
                });
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Display selected values
          if (upperSelectedValue != null)
            Positioned(
              top: 5,
              left: upperTrianglePosition - 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$upperSelectedValue',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          if (lowerSelectedValue != null)
            Positioned(
              bottom: 5,
              left: lowerTrianglePosition - 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$lowerSelectedValue',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  final bool isPointingDown;

  TrianglePainter(this.color, {this.isPointingDown = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isPointingDown) {
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
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
