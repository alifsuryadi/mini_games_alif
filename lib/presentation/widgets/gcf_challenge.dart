import 'package:flutter/material.dart';

class GCFChallenge extends StatelessWidget {
  final int value1;
  final int value2;
  final Function(int) onAnswerSubmitted;

  const GCFChallenge({
    super.key,
    required this.value1,
    required this.value2,
    required this.onAnswerSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'What is the highest\nGreatest Common Factor\nbetween these 2 values:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F51B5),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF3F51B5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$value1',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Adding number lines with triangles as shown in the design
          _buildNumberLine(1650, 1660),
          const SizedBox(height: 24),
          // Check button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Calculate GCF
                int gcf = _calculateGCF(value1, value2);
                onAnswerSubmitted(gcf);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Check Answer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberLine(int start, int end) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.lightGreen[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '$start',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
              ),
            ),
          ),
          // Line with ticks would go here
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 2,
                width: 200,
                color: Colors.lightGreen,
              ),
              Positioned(
                bottom: 10,
                child: CustomPaint(
                  size: const Size(20, 20),
                  painter: TrianglePainter(Colors.pink),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '$end',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to calculate GCF
  int _calculateGCF(int a, int b) {
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
}

// Reusing the TrianglePainter from before
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
