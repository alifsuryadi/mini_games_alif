import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_games_alif/core/styles/app_colors.dart';

class LevelCompleteDialog extends StatelessWidget {
  final int score;
  final int stars;
  final VoidCallback onContinue;
  final VoidCallback? onReplay;
  final VoidCallback? onNextLevel;
  final bool isTutorial;

  const LevelCompleteDialog({
    Key? key,
    required this.score,
    required this.stars,
    required this.onContinue,
    this.onReplay,
    this.onNextLevel,
    this.isTutorial = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300.w,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with celebration icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.celebration,
                  color: AppColors.numberYellow,
                  size: 28.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  isTutorial ? 'Tutorial Completed!' : 'Level Completed!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Score display
            Text(
              'Score: $score',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),

            // Stars display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: AnimatedScale(
                    scale: index < stars ? 1.2 : 1.0,
                    duration: Duration(milliseconds: 300 + (index * 200)),
                    curve: Curves.elasticOut,
                    child: Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color:
                          index < stars ? AppColors.numberYellow : Colors.grey,
                      size: 40.sp,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 24.h),

            // Feedback message based on stars
            Text(
              _getFeedbackMessage(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 24.h),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Replay button - only show if provided
                if (onReplay != null)
                  Expanded(
                    child: _buildButton(
                      label: 'Replay',
                      icon: Icons.replay,
                      color: AppColors.numberOrange,
                      onPressed: onReplay!,
                    ),
                  ),

                if (onReplay != null) SizedBox(width: 16.w),

                // Continue or next level button
                Expanded(
                  child: _buildButton(
                    label: onNextLevel != null ? 'Next Level' : 'Continue',
                    icon:
                        onNextLevel != null ? Icons.arrow_forward : Icons.check,
                    color: onNextLevel != null
                        ? AppColors.primary
                        : AppColors.accent,
                    onPressed: onNextLevel ?? onContinue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build consistent buttons
  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Get feedback message based on stars
  String _getFeedbackMessage() {
    if (isTutorial) {
      return 'Great job! You\'ve completed the tutorial. Now you\'re ready to play the game!';
    }

    if (stars == 3) {
      return 'Amazing work! Perfect score!';
    } else if (stars == 2) {
      return 'Well done! You\'re doing great!';
    } else if (stars == 1) {
      return 'Good job! Keep practicing to improve your score.';
    } else {
      return 'Try again to earn some stars!';
    }
  }
}
