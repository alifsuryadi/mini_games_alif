import 'package:flutter/material.dart';
import 'package:mini_games_alif/core/utils/number_line_utils.dart';

class NumberLine extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int step;
  final int targetValue;
  final Function(int) onSelect;

  const NumberLine({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.step,
    required this.targetValue,
    required this.onSelect,
  });

  @override
  State<NumberLine> createState() => _NumberLineState();
}

class _NumberLineState extends State<NumberLine> {
  double trianglePosition = 0;
  int? selectedValue;

  @override
  Widget build(BuildContext context) {
    final values = NumberLineUtils.generateNumberSteps(
        widget.minValue, widget.maxValue, widget.step);

    return LayoutBuilder(
      builder: (context, constraints) {
        final lineWidth = constraints.maxWidth - 40;
        final segmentWidth = lineWidth / (values.length - 1);

        return Stack(
          children: [
            // Number line
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // Triangle marker
                  Padding(
                    padding: EdgeInsets.only(left: trianglePosition),
                    child: CustomPaint(
                      size: const Size(30, 30),
                      painter: TrianglePainter(Colors.pink),
                    ),
                  ),

                  // Line with tick marks
                  Container(
                    height: 4,
                    color: Colors.green,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        values.length,
                        (index) => Container(
                          width: 2,
                          height: 10,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // Number labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: values.map((value) {
                      return SizedBox(
                        width: 30,
                        child: Text(
                          '$value',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Gesture detector for the entire number line
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              height: 40,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    trianglePosition = (trianglePosition + details.delta.dx)
                        .clamp(0, lineWidth);

                    // Calculate which value is closest to the current position
                    int segmentIndex = (trianglePosition / segmentWidth)
                        .round()
                        .clamp(0, values.length - 1);
                    selectedValue = values[segmentIndex];
                  });
                },
                onPanEnd: (details) {
                  if (selectedValue != null) {
                    widget.onSelect(selectedValue!);
                  }
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

            // Display the selected number
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    selectedValue != null ? '$selectedValue' : 'Drag to select',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: selectedValue != null ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize with middle position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = context.size;
        if (size != null) {
          final lineWidth = size.width - 40;
          final values = NumberLineUtils.generateNumberSteps(
            widget.minValue,
            widget.maxValue,
            widget.step,
          );

          // Find the index of the target value
          final targetIndex = values.indexOf(widget.targetValue);
          if (targetIndex != -1) {
            final segmentWidth = lineWidth / (values.length - 1);
            setState(() {
              trianglePosition = targetIndex * segmentWidth;
              selectedValue = widget.targetValue;
            });
          }
        }
      }
    });
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
