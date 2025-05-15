import 'package:accounting_app/feature/home/domain/entity/bill_entity.dart';
import 'package:accounting_app/feature/home/ui/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../data/db/data_base.dart';
import '../widgets/bill_item_builder.dart';
import 'home_page.dart';

class ImportsPage extends StatefulWidget {
  const ImportsPage({super.key});

  @override
  State<ImportsPage> createState() => _ImportsPageState();
}

class _ImportsPageState extends State<ImportsPage> {
  late final List<PlutoColumn> columns;
  late List<PlutoRow> rows;
  List<PurchaseEntity> purchases = [];

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: "المشتري",
        field: 'customer', // instead of 'price3'
        type: PlutoColumnType.text(),
        enableFilterMenuItem: false,
        enableColumnDrag: false,
        enableContextMenu: false,
        enableAutoEditing: false,
        enableDropToResize: false,
        enableHideColumnMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableSorting: false,
        enableEditingMode: false,
        enableRowDrag: false,
        enableRowChecked: false,
        filterPadding: EdgeInsets.zero,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),

      PlutoColumn(
        title: "السعر",
        field: 'price',
        type: PlutoColumnType.number(),
        textAlign: PlutoColumnTextAlign.center,
        enableFilterMenuItem: false,
        enableColumnDrag: false,
        enableContextMenu: false,
        enableAutoEditing: false,
        enableDropToResize: false,
        enableHideColumnMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableSorting: false,
        enableEditingMode: false,
        enableRowDrag: false,
        enableRowChecked: false,
        filterPadding: EdgeInsets.zero,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: "الوزن",
        field: 'weight',
        type: PlutoColumnType.number(),
        textAlign: PlutoColumnTextAlign.center,
        enableFilterMenuItem: false,
        enableColumnDrag: false,
        enableContextMenu: false,
        enableAutoEditing: false,
        enableDropToResize: false,
        enableHideColumnMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableSorting: false,
        enableEditingMode: false,
        enableRowDrag: false,
        enableRowChecked: false,
        filterPadding: EdgeInsets.zero,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: "العدد",
        field: 'count',
        type: PlutoColumnType.number(),
        textAlign: PlutoColumnTextAlign.center,
        enableFilterMenuItem: false,
        enableColumnDrag: false,
        enableContextMenu: false,
        enableAutoEditing: false,
        enableDropToResize: false,
        enableHideColumnMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableSorting: false,
        enableEditingMode: false,
        enableRowDrag: false,
        enableRowChecked: false,
        filterPadding: EdgeInsets.zero,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: "الصنف",
        field: 'fruit', // instead of 'type'
        type: PlutoColumnType.text(),
        enableFilterMenuItem: false,
        enableColumnDrag: false,
        enableContextMenu: false,
        enableAutoEditing: false,
        enableDropToResize: false,
        enableHideColumnMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableSorting: false,
        enableEditingMode: false,
        enableRowDrag: false,
        enableRowChecked: false,
        filterPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: "الاجمالي",
        field: 'total',
        type: PlutoColumnType.number(),
        textAlign: PlutoColumnTextAlign.center,
        enableFilterMenuItem: false,
        enableColumnDrag: false,
        enableContextMenu: false,
        enableAutoEditing: false,
        enableDropToResize: false,
        enableHideColumnMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableSorting: false,
        enableEditingMode: false,
        enableRowDrag: false,
        enableRowChecked: false,
        filterPadding: EdgeInsets.zero,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
    ];

    rows = [_emptyRow()];

    _loadPurchases().then((value) {
      setState(() {});
    });
  }

  Future<void> _loadPurchases() async {
    final rawRows = await FruitShopDatabase.getAllSuppliersPurchasesWithItems();

    print('rawRows count: ${rawRows}');
    final Map<int, PurchaseEntity> groupedPurchases = {};

    for (final row in rawRows) {
      // print('Row: $row');

      final int? purchaseId = row['purchase_id'] as int?;
      if (purchaseId == null) continue;

      if (!groupedPurchases.containsKey(purchaseId)) {
        groupedPurchases[purchaseId] = PurchaseEntity(
          bill: [],
          ownerName: row['supplier_name']?.toString() ?? '',
          total: (row['total_amount'] as num?)?.toDouble() ?? 0.0,
        );
      }
      final item = BillItemEntity(
        customerName:
            row['buyer_name']?.toString() ??
            '', // The customer who bought the fruit
        fruitName: row['fruit_name']?.toString() ?? '', // The fruit name
        price: (row['item_price'] as num?)?.toDouble() ?? 0.0,
        weight: (row['item_weight'] as num?)?.toDouble() ?? 0.0,
        count: (row['item_count'] as int?) ?? 0,
        type:
            row['type']?.toString() ??
            '', // Optional: if you store category/type
        total: (row['item_total'] as num?)?.toDouble() ?? 0.0,
      );

      groupedPurchases[purchaseId]!.bill.add(item);
    }

    purchases = groupedPurchases.values.toList();

    if (purchases.isNotEmpty && purchases.first.bill.isNotEmpty) {
      print('First item name: |${purchases.first.bill.first.customerName}|');
    } else {
      print('No purchases or bill items found.');
    }
    setState(() {});
  }

  PlutoRow _emptyRow() => PlutoRow(
    cells: {
      'price': PlutoCell(value: 0),
      'weight': PlutoCell(value: 0),
      'count': PlutoCell(value: 0),
      'customer': PlutoCell(value: ""),
      'total': PlutoCell(value: 0),
      'fruit': PlutoCell(value: ""),
    },
  );

  void addNewRow() {
    rows.add(_emptyRow());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(context: context, title: "الفواتير", hasPop: true),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [],
        body: BackGroundWidget(
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: PurchaseGridWidget(
                    canEdit: true,
                    columns: columns,
                    rows: rows,
                    onAddRow: addNewRow,
                  ),
                ),
                SizedBox(height: 20.h),
                ...purchases.map((e) {
                  print('eeee ${e.ownerName}');
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: PurchaseGridWidget(
                        columns: columns,
                        rows: buildPlutoRowsFromPurchase(e),
                        data: e,
                        canEdit: false,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PlutoRow> buildPlutoRowsFromPurchase(PurchaseEntity purchase) {
    return purchase.bill.map((item) {
      return PlutoRow(
        cells: {
          'price': PlutoCell(value: item.price),
          'weight': PlutoCell(value: item.weight),
          'count': PlutoCell(value: item.count),
          'customer': PlutoCell(value: item.customerName),
          'total': PlutoCell(value: item.total),
          'fruit': PlutoCell(value: item.fruitName),
        },
      );
    }).toList();
  }
}
