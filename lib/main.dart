import 'package:accounting_app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'feature/home/data/db/data_base.dart';
import 'feature/home/domain/entity/bill_entity.dart';

void main() async {
  var xx = [
    BillItemEntity(
      price: 2500,
      weight: 134,
      count: 6,
      name: "mohamed",
      total: 14900,
      type: "mango",
    ),
    BillItemEntity(
      price: 10020,
      weight: 1334,
      count: 6,
      name: "ahmed",
      total: 149001,
      type: "mango",
    ),
    BillItemEntity(
      price: 1234,
      weight: 45,
      count: 7,
      name: "ali",
      total: 45678,
      type: "mango",
    ),
  ];
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
  // final buyerId = await FruitShopDatabase.insertBuyer("Ali");
  // final fruitId = await FruitShopDatabase.insertFruit("Apple", 3.5);
  // print('Buyer ID: $buyerId');
  // print('Buyer ID: $fruitId');
  await FruitShopDatabase.insertPurchase(
    PurchaseEntity(bill: xx, buyer: "Ali", total: 1000),
  );

  final result1 = await FruitShopDatabase.searchPurchases("Ali");
  print("Search by buyer:\n$result1");

  final result2 = await FruitShopDatabase.searchPurchases("Apple");
  print("Search by fruit:\n$result2");
  runApp(MyApp());
}
