import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Jumbotron extends StatelessWidget {
  const Jumbotron({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16.h,
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 2.h,
            left: 2.h,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Solde actuel',
                style: TextStyle(
                  fontSize: 15.5.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 2.h,
            right: 2.h,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 0.5.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.w),
                  color: AppTheme.borderColorDark,
                ),
                child: Text(
                  'MGA',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 3.h,
            left: 2.h,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '20,000',
                style: TextStyle(
                  fontSize: 25.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
