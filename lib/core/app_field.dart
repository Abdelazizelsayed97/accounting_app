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
        filled: true,
        fillColor: Colors.white,
        enabled: canEdit,
        hintText: "----------------",
        hintStyle: TextStyle(color: Colors.grey.shade300),
      ),
    );
  }
}
