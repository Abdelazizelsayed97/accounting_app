import 'package:accounting_app/feature/home/data/db/data_base.dart';
import 'package:accounting_app/feature/home/ui/page/home_page.dart';
import 'package:accounting_app/feature/home/ui/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DailyOperationWidget extends StatefulWidget {
  const DailyOperationWidget({super.key});

  @override
  State<DailyOperationWidget> createState() => _DailyOperationWidgetState();
}

class _DailyOperationWidgetState extends State<DailyOperationWidget> {
  final List<TextEditingController> incomeControllers = [];
  final List<TextEditingController> spendControllers = [];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await FruitShopDatabase.archiveAndResetIfNewDay();
    final ops = await FruitShopDatabase.getTodayOperations();

    for (var op in ops) {
      final controller = TextEditingController(text: op['amount'].toString());
      if (op['type'] == 'income') {
        incomeControllers.add(controller);
      } else {
        spendControllers.add(controller);
      }
    }

    setState(() {});
  }

  double get incomeTotal => incomeControllers.fold(0.0, (sum, c) {
    final val = double.tryParse(c.text) ?? 0;
    return sum + val;
  });

  double get spendTotal => spendControllers.fold(0.0, (sum, c) {
    final val = double.tryParse(c.text) ?? 0;
    return sum + val;
  });

  double get operationResult => incomeTotal - spendTotal;

  Future<void> addRow(List<TextEditingController> list, String type) async {
    final controller = TextEditingController();
    list.add(controller);
    await FruitShopDatabase.insertOperation(0.0, type);
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in incomeControllers) {
      c.dispose();
    }
    for (final c in spendControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget buildColumn(
    String title,
    List<TextEditingController> controllers,
    VoidCallback onAdd,
    String type,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...controllers.asMap().entries.map((entry) {
            final index = entry.key;
            final c = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: c,
                keyboardType: TextInputType.number,
                onChanged: (val) async {
                  final parsed = double.tryParse(val) ?? 0.0;
                  final db = await FruitShopDatabase.database;
                  final rows = await db.query(
                    'daily_operations',
                    where: 'type = ?',
                    whereArgs: [type],
                  );
                  if (index < rows.length) {
                    await db.update(
                      'daily_operations',
                      {'amount': parsed},
                      where: 'id = ?',
                      whereArgs: [rows[index]['id']],
                    );
                  }
                  setState(() {});
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            );
          }),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text("إضافة", style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(context: context, title: "يومية", hasPop: true),
      body: BackGroundWidget(
        Center(
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.4,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      buildColumn("الواردات", incomeControllers, () {
                        addRow(incomeControllers, "income");
                      }, "income"),
                      SizedBox(width: 16.w),
                      buildColumn("المصروفات", spendControllers, () {
                        addRow(spendControllers, "spend");
                      }, "spend"),
                    ],
                  ),
                ),
                Divider(height: 32),
                Text("إجمالي الواردات: ${incomeTotal.toStringAsFixed(2)}"),
                Text("إجمالي المصروفات: ${spendTotal.toStringAsFixed(2)}"),
                SizedBox(height: 8),
                Text(
                  "صافي: ${operationResult.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: operationResult >= 0 ? Colors.green : Colors.red,
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
