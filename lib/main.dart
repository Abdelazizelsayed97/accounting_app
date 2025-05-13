import 'package:accounting_app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'feature/home/data/db/data_base.dart';
import 'feature/home/domain/entity/bill_entity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  // await WindowManager.instance.setFullScreen(true);
  await FruitShopDatabase.init();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1280, 720),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  // FruitShopDatabase.dede();
  final buyerId = await FruitShopDatabase.insertBuyer("Ali");
  final fruitId = await FruitShopDatabase.insertFruit("Apple", 3.5);
  print('Buyer ID: $buyerId');
  print('Buyer ID: $fruitId');
  await FruitShopDatabase.insertPurchase(
    PurchaseEntity(bill: [], buyer: "Ali", total: 1000),
  );

  final result1 = await FruitShopDatabase.searchPurchases("Ali");
  print("Search by buyer:\n$result1");

  final result2 = await FruitShopDatabase.searchPurchases("Apple");
  print("Search by fruit:\n$result2");
  runApp(MyApp());
}
