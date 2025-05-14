import 'package:accounting_app/core/colors.dart';
import 'package:accounting_app/feature/home/ui/page/purchases_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/gradient_app_bar.dart';
import 'daily_opration_page.dart';
import 'imports_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<String> titles = [" كشوفات", "فواتير", "زمامات", "يوميه", "جرد"];
  final List icons = [
    Icons.add,
    Icons.browse_gallery_outlined,
    Icons.money_outlined,
    Icons.abc_outlined,
    Icons.access_alarm_sharp,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(context: context, title: "Home", hasPop: false),
      body: BackGroundWidget(
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.h),
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                child: Center(
                  child: Wrap(
                    // crossAxisAlignment: WrapCrossAlignment.end,
                    alignment: WrapAlignment.end,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 8.w,
                        ),
                        child: Container(
                          constraints: constraints,
                          height: MediaQuery.sizeOf(context).height * .2,

                          // padding: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60.r),
                            gradient: LinearGradient(
                              colors: AppColors.gradientList,
                            ),
                            border: Border.all(color: Colors.greenAccent),
                          ),
                          width: MediaQuery.sizeOf(context).width * .4,
                          child: IconButton(
                            onPressed: () {
                              if (index == 0) {
                                navigateTo(context, ImportsPage());
                              } else if (index == 1) {
                                navigateTo(context, PurchasesPage());
                              } else if (index == 2) {
                                // Navigate to another page
                              } else if (index == 3) {
                                navigateTo(context, DailyOperationWidget());
                              } else if (index == 4) {
                                // Navigate to another page
                              }
                            },
                            icon: FittedBox(
                              fit: BoxFit.cover,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(icons[index], size: 18.dm),
                                  SizedBox(width: 8.w),
                                  Text(
                                    titles[index],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void toAddBillPage(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ImportsPage()),
  );

  void navigateTo(BuildContext context, Widget destination) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => destination),
  );
}

class BackGroundWidget extends StatelessWidget {
  const BackGroundWidget(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: .10,
          child: Container(
            clipBehavior: Clip.antiAlias,
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(),
            child: Image.asset(
              "lib/assets/abstract-textured-backgound.jpg",
              fit: BoxFit.cover,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
