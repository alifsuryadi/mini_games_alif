import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_games_alif/core/styles/app_colors.dart';

class AnswerControls extends StatelessWidget {
  final VoidCallback onCheckAnswer;
  final bool isCheckingAnswer;
  final bool isCorrect;

  const AnswerControls({
    Key? key,
    required this.onCheckAnswer,
    required this.isCheckingAnswer,
    required this.isCorrect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Check answer button
        Center(
          child: Container(
            width: 200.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: isCheckingAnswer
                  ? (isCorrect
                      ? AppColors.correctFeedback
                      : AppColors.incorrectFeedback)
                  : const Color(0xFF83E6B8),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: isCheckingAnswer
                    ? (isCorrect
                        ? const Color(0xFF66CC66)
                        : const Color(0xFFCC3333))
                    : const Color(0xFF59B94D),
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
              onPressed: !isCheckingAnswer ? onCheckAnswer : null,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
              child: Text(
                isCheckingAnswer
                    ? (isCorrect ? 'Correct!' : 'Try Again')
                    : 'Check Answer',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      isCheckingAnswer ? Colors.white : const Color(0xFF59B94D),
                ),
              ),
            ),
          ),
        ),

        // Feedback message
        if (isCheckingAnswer)
          Container(
            margin: EdgeInsets.only(top: 16.h),
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isCorrect
                  ? AppColors.correctFeedback.withOpacity(0.2)
                  : AppColors.incorrectFeedback.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isCorrect
                    ? AppColors.correctFeedback
                    : AppColors.incorrectFeedback,
                width: 1.w,
              ),
            ),
            child: Text(
              isCorrect
                  ? 'Great job! That\'s the correct answer.'
                  : 'Not quite right. Remember to position the markers carefully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isCorrect
                    ? const Color(0xFF338833)
                    : const Color(0xFF883333),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
