import 'package:accounting_app/feature/home/ui/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:window_manager/window_manager.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final WindowOptions windowOptions = WindowOptions();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:
          windowOptions.fullScreen == true ? Size(1280, 720) : Size(800, 600),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(backgroundColor: Colors.white),
          ),
          home: HomePage(),
        );
      },
    );
  }
}
