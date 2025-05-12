import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/colors.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    super.key,
    required this.context,
    required this.title,
    required this.hasPop,
  });

  final BuildContext context;
  final String title;
  final bool hasPop;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: kToolbarHeight.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.gradientList),
          ),
        ),
        hasPop
            ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.black,
                    size: 8.dm,
                  ),
                ),
              ],
            )
            : Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      Size(MediaQuery.sizeOf(context).width, kToolbarHeight.h);
}
