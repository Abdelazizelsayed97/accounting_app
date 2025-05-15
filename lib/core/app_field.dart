import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppField extends StatelessWidget {
  const AppField({super.key, required this.controller, required this.canEdit});

  final TextEditingController controller;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorHeight: 14.h,
      cursorColor: Colors.black,

      style: TextStyle(fontSize: 10.sp, color: Colors.black),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: Colors.grey, style: BorderStyle.solid),
        ),
        filled: true,
        fillColor: Colors.white,
        enabled: canEdit,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: Colors.grey, style: BorderStyle.solid),
        ),
      ),
    );
  }
}
