import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/colors.dart';

class PurchaseGridWidget extends StatefulWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final void Function()? onAddRow;

  const PurchaseGridWidget({
    Key? key,
    required this.columns,
    required this.rows,
    this.onAddRow,
  }) : super(key: key);

  @override
  State<PurchaseGridWidget> createState() => _PurchaseGridWidgetState();
}

class _PurchaseGridWidgetState extends State<PurchaseGridWidget> {
  PlutoGridStateManager? _stateManager;

  double get rowHeight => 20.h;

  double get headerHeight => 20.h;

  double calculateGridHeight() {
    return headerHeight + (widget.rows.length * rowHeight) + 100.h;
  }

  void updateRowTotal(PlutoRow row) {
    final price = row.cells['price']?.value ?? 0;
    final weight = row.cells['price1']?.value ?? 0;
    final count = row.cells['price2']?.value ?? 0;
    row.cells['price4']?.value = (price * weight * count).toDouble();
    _stateManager?.notifyListeners();
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: calculateGridHeight(),
      child: PlutoGrid(
        configuration: PlutoGridConfiguration(
          style: PlutoGridStyleConfig(
            defaultCellPadding: EdgeInsets.zero,
            defaultColumnFilterPadding: EdgeInsets.zero,
            defaultColumnTitlePadding: EdgeInsets.zero,
            borderColor: AppColors.primaryColor,
            gridBorderRadius: BorderRadius.circular(8.r),
            rowHeight: rowHeight,
            columnHeight: headerHeight,
          ),
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.scale,
          ),
        ),

        columns: widget.columns,
        rows: widget.rows,
        onLoaded: (event) => _stateManager = event.stateManager,
        onChanged: (event) => setState(() => updateRowTotal(event.row)),
        createFooter:
            (_) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
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
    );
  }
}
