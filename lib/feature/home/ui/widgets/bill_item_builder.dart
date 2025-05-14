import 'package:accounting_app/feature/home/domain/entity/bill_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/app_field.dart';
import '../../../../core/colors.dart';

class PurchaseGridWidget extends StatefulWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final void Function()? onAddRow;
  final PurchaseEntity? data;
  final bool canEdit;
  // final bool isPurchase;

  PurchaseGridWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.onAddRow,
    this.data,
    required this.canEdit,
    // required this.isPurchase,
  });

  @override
  State<PurchaseGridWidget> createState() => _PurchaseGridWidgetState();
}

class _PurchaseGridWidgetState extends State<PurchaseGridWidget> {
  TextEditingController controller = TextEditingController();
  PlutoGridStateManager? stateManager;

  double get rowHeight => 20.h;

  double get headerHeight => 20.h;

  double calculateGridHeight() {
    return headerHeight + (widget.rows.length * rowHeight) + 100.h;
  }

  void updateRowTotal(PlutoRow row) {
    final price = row.cells['price']?.value ?? 0;
    final weight = row.cells['price1']?.value ?? 0;
    row.cells['price4']?.value = (price * weight).toDouble();
    stateManager?.notifyListeners();
  }

  @override
  initState() {
    if (controller.text.isEmpty) {
      controller.text = widget.data?.buyer ?? '';
    }
    super.initState();
  }

  Widget buildFooterSums() {
    double totalPrice = 0;
    double totalWeight = 0;
    double grandTotal = 0;

    for (var row in widget.rows) {
      totalPrice += row.cells['price']?.value ?? 0;
      totalWeight += row.cells['price1']?.value ?? 0;
      grandTotal += row.cells['price4']?.value ?? 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("مجموع السعر: $totalPrice", style: TextStyle(fontSize: 6.sp)),
        Text("مجموع الوزن: $totalWeight", style: TextStyle(fontSize: 6.sp)),
        Text("الاجمالي الكلي: $grandTotal", style: TextStyle(fontSize: 6.sp)),
      ],
    );
  }

  // void extractBillItemsFromGrid() {
  //   if (stateManager == null) return;
  //
  //   final billItems =
  //       stateManager!.rows.map((row) {
  //         return BillItemEntity(
  //           name: row.cells['price3']?.value?.toString() ?? '',
  //           price: (row.cells['price']?.value as num?)?.toDouble() ?? 0.0,
  //           weight: (row.cells['price1']?.value as num?)?.toDouble() ?? 0.0,
  //           count: row.cells['price2']?.value as int? ?? 0,
  //           total: (row.cells['price4']?.value as num?)?.toDouble() ?? 0.0,
  //           type: row.cells['type']?.value?.toString() ?? '',
  //         );
  //       }).toList();
  //
  //   print('Collected ${billItems.length} items:');
  //   for (final item in billItems) {
  //     print('${item.name} | ${item.price} | ${item.total}');
  //   }
  //   var input = PurchaseEntity(
  //     bill: billItems,
  //     buyer: controller.text,
  //     total: 0,
  //   );
  //   FruitShopDatabase.insertPurchase(input);
  //   // Now you can use `billItems` to create a new PurchaseEntity and insert it to the DB
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Container(
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
          ),
          width: MediaQuery.of(context).size.width * 0.43,
          child: Column(
            children: [
              Text("زسكر  للخضراواتفا "),
              SizedBox(
                height: 30.h,
                child: AppField(
                  controller: controller,
                  canEdit: widget.canEdit,
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.43,
          height: calculateGridHeight(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
            child: PlutoGrid(
              // createHeader: (stateManager) {
              //   return Column(
              //     children: [
              //       Text("زسكر  للخضراواتفا "),
              //       SizedBox(
              //         height: 20.h,
              //         child: AppField(controller: controller),
              //       ),
              //     ],
              //   );
              // },
              configuration: PlutoGridConfiguration(
                columnFilter: PlutoGridColumnFilterConfig(),
                localeText: PlutoGridLocaleText(autoFitColumn: "تعبئة تلقائية"),
                style: PlutoGridStyleConfig(
                  defaultCellPadding: EdgeInsets.zero,
                  defaultColumnFilterPadding: EdgeInsets.zero,
                  defaultColumnTitlePadding: EdgeInsets.zero,
                  borderColor: AppColors.primaryColor,
                  gridBorderRadius: BorderRadius.circular(8.r),
                  columnFilterHeight: 0,
                  rowHeight: rowHeight,
                  columnHeight: headerHeight,
                ),
                columnSize: PlutoGridColumnSizeConfig(
                  autoSizeMode: PlutoAutoSizeMode.scale,
                  restoreAutoSizeAfterInsertColumn: false,
                ),
              ),
              columns: widget.columns,
              rows: widget.rows,
              onLoaded: (event) => stateManager = event.stateManager,
              onChanged: (event) => setState(() => updateRowTotal(event.row)),

              createFooter:
                  (_) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: widget.onAddRow,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.gradientList,
                              ),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            height: 20.h,
                            width: 100.w,
                            child: Text(
                              "إضافة صف جديد",
                              style: TextStyle(fontSize: 8.sp),
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        buildFooterSums(),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
