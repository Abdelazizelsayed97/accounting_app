import 'package:accounting_app/core/columns.dart';
import 'package:accounting_app/feature/home/domain/entity/bill_entity.dart';
import 'package:accounting_app/feature/home/ui/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../data/db/data_base.dart';
import '../widgets/bill_item_builder.dart';
import 'home_page.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  late final List<PlutoColumn> columns;
  late List<PlutoRow> rows;
  List<PurchaseEntity> purchases = [];

  @override
  void initState() {
    super.initState();

    columns = Columns.purchasesColumns;

    rows = [_emptyRow()];

    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    final rawRows = await FruitShopDatabase.getAllBuyerPurchasesWithItems();

    print('rawRows count: ${rawRows}');
    final Map<int, PurchaseEntity> groupedPurchases = {};

    for (final row in rawRows) {
      final int? purchaseId = row['purchase_id'] as int?;
      if (purchaseId == null) continue;

      if (!groupedPurchases.containsKey(purchaseId)) {
        groupedPurchases[purchaseId] = PurchaseEntity(
          bill: [],
          ownerName: row['buyer_name']?.toString() ?? '',
          total: (row['total_amount'] as num?)?.toDouble() ?? 0.0,
        );
      }
      final item = BillItemEntity(
        customerName: row['buyer_name']?.toString() ?? '',
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
      'price': PlutoCell(value: 0.0),
      'price1': PlutoCell(value: 0.0),
      'price2': PlutoCell(value: 0),
      'price3': PlutoCell(value: ''),
      'price4': PlutoCell(value: 0.0),
      'type': PlutoCell(value: ''),
    },
  );

  void addNewRow() {
    rows.add(_emptyRow());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(context: context, title: "كشوفات", hasPop: true),
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
                ...purchases.map(
                  (e) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: PurchaseGridWidget(
                        columns: columns,
                        rows: buildPlutoRowsFromPurchase(e),
                        data: e,
                        canEdit: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PlutoRow> buildPlutoRowsFromPurchase(PurchaseEntity purchase) {
    return purchase.bill.map((item) {
      print('Item: ${item.customerName} | ${item.price} | ${item.total}');
      return PlutoRow(
        cells: {
          'price': PlutoCell(value: item.price),
          'price1': PlutoCell(value: item.weight),
          'price2': PlutoCell(value: item.count),
          'price3': PlutoCell(value: purchase.ownerName),
          'price4': PlutoCell(value: item.total),
          'type': PlutoCell(value: item.fruitName),
        },
      );
    }).toList();
  }
}
