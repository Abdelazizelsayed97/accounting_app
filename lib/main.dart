import 'package:accounting_app/my_app.dart';
import 'package:flutter/material.dart';

import 'feature/home/data/db/data_base.dart';

void main() async {
  await FruitShopDatabase.init();

  final buyerId = await FruitShopDatabase.insertBuyer("Ali");
  final fruitId = await FruitShopDatabase.insertFruit("Apple", 3.5);
  await FruitShopDatabase.insertPurchase(buyerId, fruitId, 2);

  final result1 = await FruitShopDatabase.searchPurchasesByBuyer("Ali");
  print("Search by buyer:\n$result1");

  final result2 = await FruitShopDatabase.searchPurchasesByFruit("Apple");
  print("Search by fruit:\n$result2");
  runApp(MyApp());
}
