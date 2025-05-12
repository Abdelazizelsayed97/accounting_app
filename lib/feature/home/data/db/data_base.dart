import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FruitShopDatabase {
  static Database? _database;

  static Future<void> init() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, 'fruit_shop.db');

    _database = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
              CREATE TABLE buyers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT
              );
            ''');

          await db.execute('''
              CREATE TABLE fruits (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                price_per_kg REAL
              );
            ''');

          await db.execute('''
              CREATE TABLE purchases (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                buyer_id INTEGER,
                fruit_id INTEGER,
                quantity_kg REAL,
                total_price REAL,
                FOREIGN KEY (buyer_id) REFERENCES buyers(id),
                FOREIGN KEY (fruit_id) REFERENCES fruits(id)
              );
            ''');
        },
      ),
    );
  }

  static Future<Database> get database async {
    if (_database == null) await init();
    return _database!;
  }

  static Future<int> insertBuyer(String name) async {
    final db = await database;
    return await db.insert('buyers', {'name': name});
  }

  static Future<int> insertFruit(String name, double pricePerKg) async {
    final db = await database;
    return await db.insert('fruits', {
      'name': name,
      'price_per_kg': pricePerKg,
    });
  }

  static Future<int> insertPurchase(
    int buyerId,
    int fruitId,
    double qty,
  ) async {
    final db = await database;

    final fruit =
        (await db.query('fruits', where: 'id = ?', whereArgs: [fruitId])).first;
    final pricePerKg = fruit['price_per_kg'] as double;
    final totalPrice = pricePerKg * qty;

    return await db.insert('purchases', {
      'buyer_id': buyerId,
      'fruit_id': fruitId,
      'quantity_kg': qty,
      'total_price': totalPrice,
    });
  }

  static Future<List<Map<String, dynamic>>> searchPurchasesByBuyer(
    String name,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT p.id, b.name AS buyer_name, f.name AS fruit_name, p.quantity_kg, p.total_price
      FROM purchases p
      JOIN buyers b ON p.buyer_id = b.id
      JOIN fruits f ON p.fruit_id = f.id
      WHERE b.name LIKE ?
    ''',
      ['%$name%'],
    );
  }

  static Future<List<Map<String, dynamic>>> searchPurchasesByFruit(
    String fruitName,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT p.id, b.name AS buyer_name, f.name AS fruit_name, p.quantity_kg, p.total_price
      FROM purchases p
      JOIN buyers b ON p.buyer_id = b.id
      JOIN fruits f ON p.fruit_id = f.id
      WHERE f.name LIKE ?
    ''',
      ['%$fruitName%'],
    );
  }
}
