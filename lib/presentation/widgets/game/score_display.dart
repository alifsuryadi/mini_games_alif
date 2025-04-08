import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_games_alif/core/styles/app_colors.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final int maxScore;

  const ScoreDisplay({
    Key? key,
    required this.score,
    required this.maxScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate stars based on score percentage
    final scorePercentage = score / maxScore;
    final int stars = scorePercentage >= 0.8
        ? 3
        : (scorePercentage >= 0.6 ? 2 : (scorePercentage >= 0.4 ? 1 : 0));

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score text
          Text(
            'Score: $score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 12.w),

          // Stars display
          Row(
            children: List.generate(3, (index) {
              return Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: index < stars
                    ? AppColors.numberYellow
                    : Colors.white.withOpacity(0.5),
                size: 18.sp,
              );
            }),
          ),
        ],
      ),
    );
  }
}
