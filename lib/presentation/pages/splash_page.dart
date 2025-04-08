import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_games_alif/core/routes/app_routes.dart';
import 'package:mini_games_alif/core/styles/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60.r),
              ),
              child: Center(
                child: Icon(
                  Icons.show_chart,
                  color: AppColors.primary,
                  size: 60.sp,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              'Number Line',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'Learn math the fun way!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 48.h),

            // Loading indicator
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3.w,
            ),
          ],
        ),
      ),
    );
  }
}
