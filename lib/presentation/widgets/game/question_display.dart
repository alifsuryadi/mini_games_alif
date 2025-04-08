import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_games_alif/core/styles/app_colors.dart';
import 'package:mini_games_alif/domain/models/question_model.dart';

class QuestionDisplay extends StatelessWidget {
  final QuestionModel question;
  final int questionNumber;
  final int totalQuestions;

  const QuestionDisplay({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.questionBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          // Question number indicator
          Text(
            'Question $questionNumber of $totalQuestions',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.instructionText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),

          // Main question text
          Text(
            question.question,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.instructionText,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Optional extra instructions for tutorial
          if (question.tutorialInstructions != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                question.tutorialInstructions!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.instructionText.withOpacity(0.8),
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Special display for certain question types
          _buildQuestionSpecificContent(),
        ],
      ),
    );
  }

  Widget _buildQuestionSpecificContent() {
    // For GCF questions, show the numbers in a more prominent way
    if (question.questionType == QuestionType.gcf &&
        question.operand1 != null &&
        question.operand2 != null) {
      return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberBubble(question.operand1!),
            SizedBox(width: 24.w),
            _buildNumberBubble(question.operand2!),
          ],
        ),
      );
    }

    // For midpoint questions, visually show the range
    if (question.questionType == QuestionType.midpoint &&
        question.operand1 != null &&
        question.operand2 != null) {
      return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberBubble(question.operand1!),
            Expanded(
              child: Divider(
                color: AppColors.instructionText,
                thickness: 2.h,
                indent: 10.w,
                endIndent: 10.w,
              ),
            ),
            Icon(
              Icons.question_mark,
              color: AppColors.numberPink,
              size: 24.sp,
            ),
            Expanded(
              child: Divider(
                color: AppColors.instructionText,
                thickness: 2.h,
                indent: 10.w,
                endIndent: 10.w,
              ),
            ),
            _buildNumberBubble(question.operand2!),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNumberBubble(int number) {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: AppColors.numberPink,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
