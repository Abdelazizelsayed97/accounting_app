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
      customerName: "mohamed",
      total: 14900,
      type: "mango",
      fruitName: "mango",
    ),
    BillItemEntity(
      price: 10020,
      weight: 1334,
      count: 6,
      customerName: "ahmed",
      total: 149001,
      type: "mango",
      fruitName: "mango",
    ),
    BillItemEntity(
      price: 1234,
      weight: 45,
      count: 7,
      customerName: "ali",
      total: 45678,
      type: "mango",
      fruitName: "mango",
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

  await FruitShopDatabase.getPurchasesByDate(DateTime(2025, 5, 14));
  var zz = await FruitShopDatabase.getAllFruits();
  print('zzzzzzzzzzzzz ${zz}');
  var result = await FruitShopDatabase.insertSupplierPurchase(
    PurchaseEntity(bill: xx, ownerName: "Ali", total: 1000),
  );
  await FruitShopDatabase.insertBuyerPurchase(
    PurchaseEntity(bill: xx, ownerName: "karim", total: 1000),
  );
  print('result = $result');

  runApp(MyApp());
}
