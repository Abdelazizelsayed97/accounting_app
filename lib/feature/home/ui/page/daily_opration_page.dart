import 'package:accounting_app/feature/home/data/db/data_base.dart';
import 'package:accounting_app/feature/home/ui/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

class DailyOperationWidget extends StatefulWidget {
  const DailyOperationWidget({super.key});

  @override
  State<DailyOperationWidget> createState() => _DailyOperationWidgetState();
}

class _DailyOperationWidgetState extends State<DailyOperationWidget> {
  late List<PlutoColumn> inComeColumns;
  late List<PlutoColumn> spendColumns;
  late List<PlutoRow> inComeRows;
  late List<PlutoRow> spendRows;
  List<PlutoRow> rows = [];
  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    inComeColumns = _buildColumns("الواردات");
    spendColumns = _buildColumns("الصادرات");
    inComeRows = [];
    spendRows = [];
    initializeData();
  }

  List<PlutoColumn> _buildColumns(String title) {
    return [
      PlutoColumn(
        title: title,
        field: 'type',
        type: PlutoColumnType.select(['income', 'spend']),
        renderer: (ctx) {
          final value = ctx.cell.value;
          return Text(
            value == 'income' ? 'وارد' : 'مصروف',
            style: TextStyle(
              color: value == 'income' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          );
        },
        enableHideColumnMenuItem: true,
        enableFilterMenuItem: false,
      ),
      PlutoColumn(
        title: 'id',
        field: 'id',
        type: PlutoColumnType.text(),
        hide: true,
      ),
    ];
  }

  Future<void> initializeData() async {
    await FruitShopDatabase.archiveAndResetIfNewDay();
    final ops = await FruitShopDatabase.getTodayOperations();

    final List<PlutoRow> tempRows =
        ops.map((op) {
          return PlutoRow(
            cells: {
              'type': PlutoCell(value: op['type']),
              'amount': PlutoCell(value: op['amount'].toString()),
              'id': PlutoCell(value: op['id']),
            },
          );
        }).toList();

    setState(() {
      rows = tempRows;
    });
  }

  double get incomeTotal {
    return rows.where((row) => row.cells['type']?.value == 'income').fold(0.0, (
      sum,
      row,
    ) {
      return sum +
          (double.tryParse(row.cells['amount']?.value.toString() ?? '') ?? 0);
    });
  }

  double get spendTotal {
    return rows.where((row) => row.cells['type']?.value == 'spend').fold(0.0, (
      sum,
      row,
    ) {
      return sum +
          (double.tryParse(row.cells['amount']?.value.toString() ?? '') ?? 0);
    });
  }

  double get operationResult => incomeTotal - spendTotal;

  Future<void> onChanged(PlutoGridOnChangedEvent event) async {
    final row = event.row;
    final amount =
        double.tryParse(row.cells['amount']?.value.toString() ?? '0') ?? 0;
    final type = row.cells['type']?.value.toString();
    final id = row.cells['id']?.value;

    final db = await FruitShopDatabase.database;
    await db.update(
      'daily_operations',
      {'amount': amount, 'type': type},
      where: 'id = ?',
      whereArgs: [id],
    );

    setState(() {});
  }

  Future<void> addNewOperation(String type) async {
    final db = await FruitShopDatabase.database;
    final id = await db.insert('daily_operations', {
      'type': type,
      'amount': 0.0,
      'date': DateTime.now().toIso8601String().substring(0, 10),
    });

    final newRow = PlutoRow(
      cells: {
        'type': PlutoCell(value: type),
        'amount': PlutoCell(value: '0.0'),
        'id': PlutoCell(value: id),
      },
    );

    setState(() {
      inComeRows.add(newRow);
      stateManager.appendRows([newRow]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(context: context, title: 'اليومية', hasPop: true),
      body: Center(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * .43,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        child: PlutoGrid(
                          columns: spendColumns,
                          rows: spendRows,
                          onLoaded:
                              (event) => stateManager = event.stateManager,
                          onChanged: onChanged,
                          configuration: PlutoGridConfiguration(
                            columnSize: PlutoGridColumnSizeConfig(
                              autoSizeMode: PlutoAutoSizeMode.scale,
                            ),
                            style: PlutoGridStyleConfig(
                              gridBorderRadius: BorderRadius.circular(10.r),
                              activatedBorderColor: Colors.green,
                              activatedColor: Colors.lightGreen,
                              rowHeight: 40.h,
                              columnHeight: 45.h,
                            ),
                            localeText: const PlutoGridLocaleText(),
                            tabKeyAction:
                                PlutoGridTabKeyAction.moveToNextOnEdge,
                          ),
                          noRowsWidget: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => addNewOperation('spend'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: PlutoGrid(
                          columns: inComeColumns,
                          rows: inComeRows,
                          onLoaded:
                              (event) => stateManager = event.stateManager,
                          onChanged: onChanged,
                          configuration: PlutoGridConfiguration(
                            columnSize: PlutoGridColumnSizeConfig(
                              autoSizeMode: PlutoAutoSizeMode.scale,
                            ),
                            style: PlutoGridStyleConfig(
                              gridBorderRadius: BorderRadius.circular(10.r),
                              activatedBorderColor: Colors.green,
                              activatedColor: Colors.lightGreen,
                              rowHeight: 40.h,
                              columnHeight: 45.h,
                            ),
                            localeText: const PlutoGridLocaleText(),
                          ),
                          noRowsWidget: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => addNewOperation('income'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(height: 20.h),
                Text("إجمالي الإيرادات: ${incomeTotal.toStringAsFixed(2)}"),
                Text("إجمالي المصروفات: ${spendTotal.toStringAsFixed(2)}"),
                SizedBox(height: 6.h),
                Text(
                  "الصافي: ${operationResult.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16.sp,
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
