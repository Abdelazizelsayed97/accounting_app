import 'package:accounting_app/feature/home/domain/entity/bill_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pluto_grid/pluto_grid.dart';
import 'package:printing/printing.dart';

import '../../../../core/app_field.dart';
import '../../../../core/colors.dart';
import '../../data/db/data_base.dart';

class PurchaseGridWidget extends StatefulWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final void Function()? onAddRow;
  final PurchaseEntity? data;
  final bool canEdit;
  final bool isPurchasePage;

  const PurchaseGridWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.onAddRow,
    this.data,
    required this.canEdit,
    required this.isPurchasePage,
  });

  @override
  State<PurchaseGridWidget> createState() => _PurchaseGridWidgetState();
}

class _PurchaseGridWidgetState extends State<PurchaseGridWidget> {
  final TextEditingController controller = TextEditingController();
  PlutoGridStateManager? stateManager;

  double discount = 0.0;
  double paidAmount = 0.0;

  double get rowHeight => 20.h;

  double get headerHeight => 20.h;

  double calculateGridHeight() {
    return headerHeight + (widget.rows.length * rowHeight) + 40.h;
  }

  double get grandTotal {
    double total = 0;
    for (var row in widget.rows) {
      total += row.cells['total']?.value ?? 0;
    }
    return total;
  }

  double get finalAmount => grandTotal - discount;

  double get remainingAmount => finalAmount - paidAmount;

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
    super.initState();
    controller.text = widget.data?.ownerName ?? '';
  }

  Future<void> printBill(
    List<BillItemEntity> billItems,
    String ownerName,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('فاتورة المشتريات', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 10),
              pw.Text('الاسم: $ownerName'),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  'العميل',
                  'الصنف',
                  'السعر',
                  'الوزن',
                  'العدد',
                  'الاجمالي',
                ],
                data:
                    billItems.map((item) {
                      return [
                        item.customerName,
                        item.fruitName,
                        item.price.toString(),
                        item.weight.toString(),
                        item.count.toString(),
                        item.total.toString(),
                      ];
                    }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  TableRow _buildTableRow(
    String title,
    String value, {
    bool isEditable = false,
    void Function(String)? onChanged,
  }) {
    return TableRow(
      decoration: BoxDecoration(),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(title, style: TextStyle(fontSize: 8.sp)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child:
              isEditable
                  ? TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: onChanged,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 8.sp),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                    ),
                  )
                  : Text(value, style: TextStyle(fontSize: 8.sp)),
        ),
      ],
    );
  }

  Widget buildSummaryTableForPurchases() {
    return Table(
      defaultColumnWidth: FixedColumnWidth(30.w),
      border: TableBorder.all(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _buildTableRow(
          "تنزيل",
          discount.toStringAsFixed(2),
          isEditable: true,
          onChanged:
              (val) => setState(() => discount = double.tryParse(val) ?? 0.0),
        ),
        _buildTableRow(
          "عموله",
          (grandTotal + (grandTotal * .08)).toStringAsFixed(2),
          onChanged:
              (val) => setState(() => discount = double.tryParse(val) ?? 0.0),
        ),
        _buildTableRow(
          "المجموع الكلي",
          grandTotal.toStringAsFixed(2),
          onChanged: (p0) => setState(() {}),
        ),
      ],
    );
  }

  Widget buildSummaryTableForImports() {
    return Table(
      defaultColumnWidth: FixedColumnWidth(30.w),
      border: TableBorder.all(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _buildTableRow(
          "تنزيل",
          discount.toStringAsFixed(1),
          isEditable: true,
          onChanged: (val) {
            setState(() => discount = double.tryParse(val) ?? 0.0);
          },
        ),
        _buildTableRow(
          "عموله",
          remainingAmount.toStringAsFixed(1),
          isEditable: true,
          onChanged: (p0) => setState(() {}),
        ),

        _buildTableRow(
          "ناولون",
          paidAmount.toStringAsFixed(2),
          isEditable: true,
          onChanged: (val) {
            setState(() => paidAmount = double.tryParse(val) ?? 0.0);
          },
        ),
        _buildTableRow(
          "المجموع الكلي",
          grandTotal.toStringAsFixed(1),
          onChanged: (p0) => setState(() {}),
        ),
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
                  "سكر للخضراوات",
                  style: TextStyle(color: Colors.black, fontSize: 16.sp),
                ),
                SizedBox(
                  height: 30.h,
                  child: Row(
                    children: [
                      SizedBox(width: 8.w),
                      Flexible(
                        child: AppField(
                          controller: controller,
                          canEdit: widget.canEdit,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text("/الاسم", style: TextStyle(fontSize: 8.sp)),
                      SizedBox(width: 8.w),
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
              onChanged: (event) => updateRowTotal(event.row),
            ),
          ),
          // SizedBox(height: 12.h),
          SizedBox(
            width: MediaQuery.sizeOf(context).width * .2,
            height: 100.h,
            child:
                widget.isPurchasePage
                    ? buildSummaryTableForPurchases()
                    : buildSummaryTableForImports(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "الاجمالي الكلي: ${widget.data?.total ?? 0}",
                  style: TextStyle(fontSize: 6.sp),
                ),
                IconButton(
                  onPressed: () {
                    extractBillItemsFromGrid();
                    setState(() {});
                  },
                  icon: Icon(Icons.edit, color: Colors.grey.shade400),
                ),
                if (widget.canEdit) ...[
                  IconButton(
                    onPressed: () {
                      extractBillItemsFromGrid();
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.save_outlined,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
                IconButton(
                  onPressed:
                      () => printBill(widget.data?.bill ?? [], controller.text),
                  icon: Icon(Icons.print, color: Colors.grey.shade400),
                ),
                widget.canEdit
                    ? Text(widget.data?.date ?? "ggggggg")
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void extractBillItemsFromGrid() {
    if (stateManager == null) return;
    print('stateManager ${discount.toString()}');

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

            // These now reflect values from summary fields:
            delivery: paidAmount.toString(),
            services: remainingAmount.toString(),
            tax: discount.toString(),
          );
        }).toList();

    var input = PurchaseEntity(
      bill: billItems,
      ownerName: controller.text,
      total: finalAmount,
      date: DateTime.now().toString(),
    );

    FruitShopDatabase.insertSupplierPurchase(input).then((value) {
      setState(() {
        stateManager?.rows.clear();
      });
    });
  }
}
