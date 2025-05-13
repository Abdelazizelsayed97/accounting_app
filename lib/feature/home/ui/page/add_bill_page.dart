import 'package:accounting_app/feature/home/domain/entity/bill_entity.dart';
import 'package:accounting_app/feature/home/ui/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../data/db/data_base.dart';
import '../widgets/bill_item_builder.dart';
import 'home_page.dart';

class AddBillPage extends StatefulWidget {
  const AddBillPage({super.key});

  @override
  State<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends State<AddBillPage> {
  late final List<PlutoColumn> columns;
  late List<PlutoRow> rows;
  List<PurchaseEntity> purchases = [];

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: "الاسم",
        field: 'price3',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: "السعر",
        field: 'price',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: "الوزن",
        field: 'price1',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: "العدد",
        field: 'price2',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: "الاجمالي",
        field: 'price4',
        type: PlutoColumnType.number(),
      ),
    ];

    rows = [_emptyRow()];

    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    final data = await FruitShopDatabase.getAllPurchases();
    purchases = data.map((e) => PurchaseEntity.fromMap(e)).toList();
    setState(() {});
  }

  PlutoRow _emptyRow() => PlutoRow(
    cells: {
      'price': PlutoCell(value: 0.0),
      'price1': PlutoCell(value: 0.0),
      'price2': PlutoCell(value: 0),
      'price3': PlutoCell(value: ''),
      'price4': PlutoCell(value: 0.0),
    },
  );

  void addNewRow() {
    rows.add(_emptyRow());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        context: context,
        title: "اضافه فاتوره",
        hasPop: true,
      ),
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
                    columns: columns,
                    rows: rows,
                    onAddRow: addNewRow,
                  ),
                ),
                SizedBox(height: 20.h),
                ...purchases.map(
                  (e) => ListTile(
                    title: Text("تاجر: ${e.buyer}"),
                    subtitle: Text("الاجمالي: ${e.total}"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
