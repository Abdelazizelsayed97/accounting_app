import 'package:accounting_app/feature/home/domain/entity/bill_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/app_field.dart';
import '../../../../core/colors.dart';
import '../../data/db/data_base.dart';

class PurchaseGridWidget extends StatefulWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final void Function()? onAddRow;
  final PurchaseEntity? data;
  final bool canEdit;

  const PurchaseGridWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.onAddRow,
    this.data,
    required this.canEdit,
  });

  @override
  State<PurchaseGridWidget> createState() => _PurchaseGridWidgetState();
}

class _PurchaseGridWidgetState extends State<PurchaseGridWidget> {
  final TextEditingController controller = TextEditingController();
  PlutoGridStateManager? stateManager;

  double get rowHeight => 20.h;

  double get headerHeight => 20.h;

  double calculateGridHeight() {
    return headerHeight + (widget.rows.length * rowHeight) + 100.h;
  }

  void updateRowTotal(PlutoRow row) {
    final price = row.cells['price']?.value ?? 0;
    final weight = row.cells['weight']?.value ?? 0;
    row.cells['total']?.value = (price * weight).toDouble();
    stateManager?.notifyListeners();
  }

  void addNewRow() {
    final newRow = stateManager?.getNewRow();
    if (newRow != null) {
      stateManager?.appendRows([newRow]);
    }
    setState(() {});
  }

  @override
  void initState() {
    print('data ==== ${widget.data?.ownerName}');
    super.initState();
    controller.text = widget.data?.ownerName ?? '';
  }

  Widget buildFooterSums() {
    double totalPrice = 0;
    double totalWeight = 0;
    double grandTotal = 0;

    for (var row in widget.rows) {
      totalPrice += row.cells['price']?.value ?? 0;
      totalWeight += row.cells['weight']?.value ?? 0;
      grandTotal += row.cells['total']?.value ?? 0;
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      width: MediaQuery.of(context).size.width * 0.43,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Column(
              children: [
                Text(
                  "زسكر للخضراوات",
                  style: TextStyle(color: Colors.black, fontSize: 16.sp),
                ),
                SizedBox(
                  height: 30.h,
                  child: Row(
                    children: [
                      if (widget.canEdit) ...[
                        GestureDetector(
                          onTap: () {
                            extractBillItemsFromGrid();
                            setState(() {});
                          },
                          child: Text(
                            "حفظ",
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(width: 8.w),
                      Flexible(
                        child: AppField(
                          controller: controller,
                          canEdit: widget.canEdit,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            height: calculateGridHeight(),
            child: PlutoGrid(
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
                        if (widget.canEdit)
                          GestureDetector(
                            onTap: addNewRow,
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
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Row(
              children: [
                Text(
                  "الاجمالي الكلي: ${widget.data?.total ?? 0}",
                  style: TextStyle(fontSize: 6.sp),
                ),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(),
                  child: Text(
                    "تعديل",
                    style: TextStyle(fontSize: 8.sp, color: Colors.cyan),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void extractBillItemsFromGrid() {
    if (stateManager == null) return;

    final billItems =
        stateManager!.rows.map((row) {
          return BillItemEntity(
            customerName: row.cells['customer']?.value?.toString() ?? '',
            price: (row.cells['price']?.value as num?)?.toDouble() ?? 0.0,
            weight: (row.cells['weight']?.value as num?)?.toDouble() ?? 0.0,
            count: row.cells['count']?.value as int? ?? 0,
            total: (row.cells['item_total']?.value as num?)?.toDouble() ?? 0.0,
            type: row.cells['type']?.value?.toString() ?? '',
            fruitName: row.cells['type']?.value?.toString() ?? '',
          );
        }).toList();

    print('Collected ${billItems.length} items:');
    for (final item in billItems) {
      print('${item.customerName} | ${item.price} | ${item.total}');
    }
    var input = PurchaseEntity(
      bill: billItems,
      ownerName: controller.text,
      total: 0,
    );
    FruitShopDatabase.insertSupplierPurchase(input).then((value) {
      setState(() {
        stateManager?.rows.clear();
      });
    });
    // Now you can use `billItems` to create a new PurchaseEntity and insert it to the DB
  }
}
