import 'package:accounting_app/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/gradient_app_bar.dart';
import 'add_bill_page.dart';
import 'history_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<String> titles = [
    "اضافه فاتوره",
    "جرد",
    "يوميه",
    " كشوفات",
    "فواتير",
  ];
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
                child: FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 8,
                        ),
                        child: Container(
                          constraints: constraints,
                          height: 48.h,

                          // padding: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.r),
                            gradient: LinearGradient(
                              colors: AppColors.gradientList,
                            ),
                            border: Border.all(color: Colors.greenAccent),
                          ),
                          width: MediaQuery.sizeOf(context).width * .2,
                          child: IconButton(
                            onPressed: () {
                              if (index == 0) {
                              } else if (index == 1) {
                              } else if (index == 2) {
                                // Navigate to another page
                              } else if (index == 3) {
                                toHistoryPage(context);
                                // Navigate to another page
                              } else if (index == 4) {
                                toAddBillPage(context);
                                // Navigate to another page
                              }
                            },
                            icon: FittedBox(
                              fit: BoxFit.cover,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(icons[index], size: 16.dm),
                                  SizedBox(width: 8.w),
                                  Text(
                                    titles[index],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
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
    MaterialPageRoute(builder: (context) => AddBillPage()),
  );

  void toHistoryPage(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => HistoryPage()),
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
          opacity: .15,
          child: Container(
            clipBehavior: Clip.antiAlias,
            width: double.infinity,
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
