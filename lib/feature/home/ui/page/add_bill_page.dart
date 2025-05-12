import 'package:accounting_app/feature/home/ui/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/app_field.dart';
import 'home_page.dart';

class AddBillPage extends StatefulWidget {
  AddBillPage({super.key});

  @override
  State<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends State<AddBillPage> {
  @override
  initState() {
    super.initState();
  }

  late final PlutoGridStateManager stateManager;
  // void getData() async {
  //   final data = FruitShopDatabase.print(data);
  // }
  // void insertPurchase(){
  //  FruitShopDatabase.insertPurchase(, fruitId, qty)
  // }

  List<PlutoColumn> xx = [
    PlutoColumn(title: "السعر", field: 'price', type: PlutoColumnType.number()),
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
    PlutoColumn(title: "الاسم", field: 'price3', type: PlutoColumnType.text()),
    PlutoColumn(
      title: "الاجمالي",
      field: "price4",
      type: PlutoColumnType.number(),
    ),
  ];

  List<PlutoRow> cc = [
    PlutoRow(
      cells: {
        'price': PlutoCell(value: 0),
        'price1': PlutoCell(value: 0),
        'price2': PlutoCell(value: 0),
        'price3': PlutoCell(value: 0),
        'price4': PlutoCell(value: 0),
      },
    ),
  ];

  void updateRowTotal(PlutoRow row) {
    final price = row.cells['price']?.value ?? 0;
    final weight = row.cells['price1']?.value ?? 0;
    final count = row.cells['price2']?.value ?? 0;

    // Example formula: total = price * weight * count
    final total = (price * weight * count).toDouble();

    row.cells['price4']?.value = total;

    stateManager.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        context: context,
        title: "اضافه فاتوره",
        hasPop: true,
      ),
      body: BackGroundWidget(
        Column(
          children: [
            Expanded(
              child: PlutoGrid(
                columns: xx,
                rows: cc,
                onLoaded: (event) {
                  stateManager = event.stateManager;
                },
                onChanged: (PlutoGridOnChangedEvent event) {
                  setState(() {
                    updateRowTotal(event.row);
                  });
                },

                createFooter: (stateManager) {
                  return ElevatedButton(
                    onPressed: addNewRow,
                    child: Text("إضافة صف جديد"),
                  );
                },
              ),
            ),
            buildFooterSums(),
          ],
        ),
      ),
    );
  }

  Widget buildFooterSums() {
    double totalPrice = 0;
    double totalWeight = 0;
    // double totalCount = 0;
    double grandTotal = 0;

    for (var row in cc) {
      totalPrice += row.cells['price']?.value ?? 0;
      totalWeight += row.cells['price1']?.value ?? 0;
      // totalCount += row.cells['price2']?.value ?? 0;
      grandTotal += row.cells['price4']?.value ?? 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("مجموع السعر: $totalPrice", style: TextStyle(fontSize: 6.sp)),
        Text("مجموع الوزن: $totalWeight", style: TextStyle(fontSize: 6.sp)),
        // Text("مجموع العدد: $totalCount", style: TextStyle(fontSize: 6.sp)),
        Text("الاجمالي الكلي: $grandTotal", style: TextStyle(fontSize: 6.sp)),
      ],
    );
  }

  Widget billItemBuilder(TextEditingController controller, String title) {
    return ListTile(
      title: AppField(controller: controller),
      trailing: Text(title),
    );
  }

  void addNewRow() {
    final newRow = PlutoRow(
      cells: {
        'price': PlutoCell(value: 0.0),
        'price1': PlutoCell(value: 0.0),
        'price2': PlutoCell(value: 0),
        'price3': PlutoCell(value: ''),
        'price4': PlutoCell(value: 0.0),
      },
    );

    stateManager.appendRows([newRow]);
    // cc.add(newRow); // Update your list too
  }
}
