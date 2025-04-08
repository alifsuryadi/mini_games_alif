import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_games_alif/core/styles/app_colors.dart';

class TutorialOverlay extends StatelessWidget {
  final int tutorialStep;
  final VoidCallback onNext;
  final String tutorialType;

  const TutorialOverlay({
    Key? key,
    required this.tutorialStep,
    required this.onNext,
    this.tutorialType = 'basic',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (tutorialType) {
      case 'gcf':
        return _buildGcfTutorial(context);
      case 'addition':
        return _buildAdditionTutorial(context);
      case 'subtraction':
        return _buildSubtractionTutorial(context);
      case 'midpoint':
        return _buildMidpointTutorial(context);
      case 'basic':
      default:
        return _buildBasicTutorial(context);
    }
  }

  Widget _buildBasicTutorial(BuildContext context) {
    switch (tutorialStep) {
      case 0:
        return _buildTutorialStep(
          context,
          title: 'Selamat Datang di Number Line!',
          content:
              'Permainan ini akan membantumu memahami bagaimana menempatkan angka pada garis bilangan.',
          targetPosition: const Offset(0.5, 0.3),
          arrowDirection: ArrowDirection.down,
        );

      case 1:
        return _buildTutorialStep(
          context,
          title: 'Zoom Slider',
          content:
              'Gunakan slider atas dengan kotak oranye untuk memperbesar bagian tertentu dari garis bilangan.',
          targetPosition: const Offset(0.5, 0.2),
          arrowDirection: ArrowDirection.down,
          highlightWidget: true,
        );

      case 2:
        return _buildTutorialStep(
          context,
          title: 'Segitiga Penanda',
          content:
              'Geser segitiga merah muda untuk menandai jawaban. Untuk soal identifikasi angka, kedua segitiga harus ditempatkan pada posisi yang sama.',
          targetPosition: const Offset(0.5, 0.55),
          arrowDirection: ArrowDirection.up,
          highlightWidget: true,
        );

      case 3:
        return _buildTutorialStep(
          context,
          title: 'Periksa Jawaban',
          content:
              'Setelah yakin dengan jawaban, tekan tombol "Check Answer" untuk memeriksa apakah jawaban benar.',
          targetPosition: const Offset(0.5, 0.85),
          arrowDirection: ArrowDirection.up,
          highlightWidget: true,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGcfTutorial(BuildContext context) {
    switch (tutorialStep) {
      case 0:
        return _buildTutorialStep(
          context,
          title: 'Soal Faktor Persekutuan Terbesar (FPB)',
          content:
              'Pada soal ini, kamu diminta menemukan Faktor Persekutuan Terbesar dari dua bilangan.',
          targetPosition: const Offset(0.5, 0.25),
          arrowDirection: ArrowDirection.down,
        );

      case 1:
        return _buildTutorialStep(
          context,
          title: 'Kedua Bilangan',
          content:
              'Perhatikan kedua bilangan yang ditampilkan. Kamu perlu mencari FPB dari kedua bilangan tersebut.',
          targetPosition: const Offset(0.5, 0.35),
          arrowDirection: ArrowDirection.down,
          highlightWidget: true,
        );

      case 2:
        return _buildTutorialStep(
          context,
          title: 'Temukan FPB',
          content:
              'Geser kedua segitiga ke posisi yang menunjukkan FPB dari kedua bilangan tersebut.',
          targetPosition: const Offset(0.5, 0.55),
          arrowDirection: ArrowDirection.up,
          highlightWidget: true,
        );

      case 3:
        return _buildTutorialStep(
          context,
          title: 'Periksa Jawaban',
          content:
              'Setelah segitiga ditempatkan pada FPB, tekan tombol "Check Answer".',
          targetPosition: const Offset(0.5, 0.85),
          arrowDirection: ArrowDirection.up,
          highlightWidget: true,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAdditionTutorial(BuildContext context) {
    switch (tutorialStep) {
      case 0:
        return _buildTutorialStep(
          context,
          title: 'Soal Penjumlahan',
          content:
              'Pada soal penjumlahan, kamu akan menggunakan garis bilangan untuk menunjukkan hasil penjumlahan.',
          targetPosition: const Offset(0.5, 0.25),
          arrowDirection: ArrowDirection.down,
        );

      case 1:
        return _buildTutorialStep(
          context,
          title: 'Bilangan Pertama',
          content:
              'Segitiga bawah sudah ditempatkan pada bilangan pertama dalam soal penjumlahan.',
          targetPosition: const Offset(0.3, 0.5),
          arrowDirection: ArrowDirection.down,
          highlightWidget: true,
        );

      case 2:
        return _buildTutorialStep(
          context,
          title: 'Temukan Hasil Penjumlahan',
          content:
              'Geser segitiga atas ke posisi yang menunjukkan hasil penjumlahan kedua bilangan tersebut.',
          targetPosition: const Offset(0.7, 0.6),
          arrowDirection: ArrowDirection.up,
          highlightWidget: true,
        );

      case 3:
        return _buildTutorialStep(
          context,
          title: 'Periksa Jawaban',
          content:
              'Setelah segitiga atas ditempatkan pada hasil penjumlahan, tekan tombol "Check Answer".',
          targetPosition: const Offset(0.5, 0.85),
          arrowDirection: ArrowDirection.up,
          highlightWidget: true,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSubtractionTutorial(BuildContext context) {
    switch (tutorialStep) {
      case 0:
        return _buildTutorialStep(
          context,
          title: 'Soal Pengurangan',
          content:
              'Pada soal pengurangan, kamu akan menggunakan garis bilangan untuk menunjukkan hasil pengurangan.',
          targetPosition: const Offset(0.5, 0.25),
          arrowDirection: ArrowDirection.down,
        );

      case 1:
        return _buildTutorialStep(
          context,
          title: 'Bilangan Awal',
          content:
              'Segitiga bawah sudah ditempatkan pada bilangan pertama (yang dikurangi) dalam soal pengurangan.',
          targetPosition: const Offset(0.7, 0.5),
          arrowDirection: ArrowDirection.down,
          highlightWidget: true,
        );

      case 2:
        return _buildTutorialStep(
          context,
          title: 'Temukan Hasil Pengurangan',
          content:
              'Geser segitiga atas ke posisi yang menunjukkan hasil pengurangan kedua bilangan tersebut.',
          targetPosition: const Offset(0.3, 0.6),
          arrowDirection: ArrowDirection.up,
          highlightWidget: true,
        );

      case 3:
        return _buildTutorialStep(
          context,
          title: 'Periksa Jawaban',
          content:
              'Setelah segitiga atas ditempatkan pada hasil pengurangan, tekan tombol "Check Answer".',
          targetPosition: const Offset(0.5, 0.85),
          arrowDirection: ArrowDirection.up,
          highlightWidget: true,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMidpointTutorial(BuildContext context) {
    switch (tutorialStep) {
      case 0:
        return _buildTutorialStep(
          context,
          title: 'Soal Titik Tengah',
          content:
              'Pada soal ini, kamu diminta menemukan titik tengah (nilai tengah) antara dua bilangan.',
          targetPosition: const Offset(0.5, 0.25),
          arrowDirection: ArrowDirection.down,
        );

      case 1:
        return _buildTutorialStep(
          context,
          title: 'Bilangan Pertama',
          content: 'Tempatkan segitiga bawah pada bilangan pertama.',
          targetPosition: const Offset(0.3, 0.5),
          arrowDirection: ArrowDirection.down,
          highlightWidget: true,
        );

      case 2:
        return _buildTutorialStep(
          context,
          title: 'Bilangan Kedua',
          content: 'Tempatkan segitiga atas pada bilangan kedua.',
          targetPosition: const Offset(0.7, 0.6),
          arrowDirection: ArrowDirection.up,
          highlightWidget: true,
        );

      case 3:
        return _buildTutorialStep(
          context,
          title: 'Periksa Jawaban',
          content:
              'Setelah kedua segitiga ditempatkan pada kedua bilangan, tekan tombol "Check Answer" untuk melihat nilai tengahnya.',
          targetPosition: const Offset(0.5, 0.85),
          arrowDirection: ArrowDirection.up,
          highlightWidget: true,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTutorialStep(
    BuildContext context, {
    required String title,
    required String content,
    required Offset targetPosition,
    required ArrowDirection arrowDirection,
    bool highlightWidget = false,
  }) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Semi-transparent background
        Positioned.fill(
          child: GestureDetector(
            onTap: onNext,
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
          bottom: arrowDirection == ArrowDirection.down ? 120.h : 20.h,
          top: arrowDirection == ArrowDirection.up ? 120.h : null,
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
                  onTap: onNext,
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
        if (arrowDirection == ArrowDirection.down)
          Positioned(
            left: targetPosition.dx * screenSize.width - 10.w,
            bottom: (1 - targetPosition.dy) * screenSize.height,
            child: CustomPaint(
              size: Size(20.w, 30.h),
              painter: ArrowPainter(direction: ArrowDirection.down),
            ),
          )
        else
          Positioned(
            left: targetPosition.dx * screenSize.width - 10.w,
            top: targetPosition.dy * screenSize.height,
            child: CustomPaint(
              size: Size(20.w, 30.h),
              painter: ArrowPainter(direction: ArrowDirection.up),
            ),
          ),
      ],
    );
  }
}

enum ArrowDirection { up, down }

class ArrowPainter extends CustomPainter {
  final ArrowDirection direction;

  ArrowPainter({required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    if (direction == ArrowDirection.down) {
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
