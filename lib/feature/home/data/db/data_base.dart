import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../domain/entity/bill_entity.dart';

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
          // Create tables here
          await db.execute('''
              CREATE TABLE buyers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP
              );
            ''');

          // Create fruits table
          await db.execute('''
              CREATE TABLE fruits (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT UNIQUE,
                price_per_kg REAL,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP
              );
            ''');
          await db.execute('''
          CREATE TABLE IF NOT EXISTS daily_operations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            type TEXT CHECK(type IN ('income', 'spend')) NOT NULL,
            date TEXT NOT NULL
          )
        ''');
          await db.execute('''
          CREATE TABLE IF NOT EXISTS daily_operations_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            total_income REAL,
            total_spend REAL,
            date TEXT NOT NULL
          )
        ''');
          // Create purchases table
          await db.execute('''
CREATE TABLE purchases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  buyer_id INTEGER,
  total_amount REAL,
  date TEXT DEFAULT CURRENT_TIMESTAMP,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  type TEXT DEFAULT 'fruits',
  FOREIGN KEY (buyer_id) REFERENCES buyers(id) ON DELETE CASCADE
)
''');
          // create
          // Create bill_items table
          await db.execute('''
              CREATE TABLE bill_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                purchase_id INTEGER,
                fruit_id INTEGER,
                price REAL,
                weight REAL,
                count INTEGER,
                total REAL,
                FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
                FOREIGN KEY (fruit_id) REFERENCES fruits(id) ON DELETE RESTRICT
              );
            ''');

          // Create daily_finances table
          await db.execute('''
              CREATE TABLE daily_finances (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT UNIQUE,
                gained_money REAL DEFAULT 0.0,
                spent_money REAL DEFAULT 0.0,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP
              );
            ''');

          // Create indexes for faster searches
          await db.execute(
            'CREATE INDEX idx_purchases_date ON purchases(date);',
          );
          await db.execute(
            'CREATE INDEX idx_purchases_buyer_id ON purchases(buyer_id);',
          );
          await db.execute(
            'CREATE INDEX idx_bill_items_purchase_id ON bill_items(purchase_id);',
          );
          await db.execute(
            'CREATE INDEX idx_bill_items_fruit_id ON bill_items(fruit_id);',
          );
          await db.execute(
            'CREATE INDEX idx_daily_finances_date ON daily_finances(date);',
          );
        },
      ),
    );
  }

  // Purchase operations
  static Future<int> insertPurchase(PurchaseEntity purchase) async {
    final db = await database;
    final batch = db.batch();

    // 1. Insert the purchase header
    final purchaseId = await db.insert('purchases', {
      'buyer_id': await _getBuyerId(purchase.buyer),
      'total_amount': purchase.total,
    });

    // 2. Insert all bill items
    for (final item in purchase.bill) {
      final fruitId = await _getFruitId(item.name);
      await db.insert('bill_items', {
        'purchase_id': purchaseId,
        'fruit_id': fruitId,
        'price': item.price,
        'weight': item.weight,
        'count': item.count,
        'total': item.total,
      });
    }

    // 3. Update daily gained money
    await _updateDailyGainedMoney(DateTime.now(), purchase.total.toDouble());

    return purchaseId;
  }

  static Future<Database> get database async {
    if (_database == null) await init();
    return _database!;
  }

  static void dede() async {
    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, 'fruit_shop.db');
    if (_database != null) {
      print('-------------');
      // await _database!.delete("purchases");
      await databaseFactory.deleteDatabase(path);
    }
  }

  // Buyer operations
  static Future<int> insertBuyer(String name) async {
    final db = await database;
    return await db.insert('buyers', {'name': name});
  }

  static Future<List<Map<String, dynamic>>> getAllBuyers() async {
    final db = await database;
    return await db.query('buyers');
  }

  // Fruit operations
  static Future<int> insertFruit(String name, double pricePerKg) async {
    final db = await database;

    // Check if the fruit already exists
    final existingFruit = await db.query(
      'fruits',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (existingFruit.isNotEmpty) {
      // If fruit exists, update its price (or any other field like stock/amount)
      final fruitId = existingFruit.first['id'] as int;
      await db.update(
        'fruits',
        {
          'price_per_kg': pricePerKg, // or another field to update
        },
        where: 'id = ?',
        whereArgs: [fruitId],
      );
      return fruitId; // Return the ID of the existing fruit
    } else {
      // Insert new fruit if it doesn't exist
      return await db.insert('fruits', {
        'name': name,
        'price_per_kg': pricePerKg,
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getAllFruits() async {
    final db = await database;
    return await db.query('fruits');
  }

  static Future<int> _getBuyerId(String buyerName) async {
    final db = await database;
    final buyers = await db.query(
      'buyers',
      where: 'name = ?',
      whereArgs: [buyerName],
    );

    if (buyers.isNotEmpty) {
      return buyers.first['id'] as int;
    } else {
      // Create the buyer if not exists
      return await insertBuyer(buyerName);
    }
  }

  static Future<int> _getFruitId(String fruitName) async {
    final db = await database;
    final fruits = await db.query(
      'fruits',
      where: 'name = ?',
      whereArgs: [fruitName],
    );

    if (fruits.isNotEmpty) {
      return fruits.first['id'] as int;
    } else {
      // Returning -1 if fruit doesn't exist (you should handle this case)
      return -1;
    }
  }

  // Daily finance operations
  static Future<int> insertDailyGainedMoney(
    DateTime date,
    double amount,
  ) async {
    return await _updateDailyGainedMoney(date, amount);
  }

  static Future<int> insertDailySpentMoney(DateTime date, double amount) async {
    return await _updateDailySpentMoney(date, amount);
  }

  static Future<int> _updateDailyGainedMoney(
    DateTime date,
    double amount,
  ) async {
    final db = await database;
    final dateStr = _formatDate(date);

    // Check if entry exists for this date
    final existingEntries = await db.query(
      'daily_finances',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (existingEntries.isEmpty) {
      // Create new entry
      return await db.insert('daily_finances', {
        'date': dateStr,
        'gained_money': amount,
        'spent_money': 0.0,
      });
    } else {
      // Update existing entry
      final currentGained = existingEntries.first['gained_money'] as double;
      return await db.update(
        'daily_finances',
        {'gained_money': currentGained + amount},
        where: 'date = ?',
        whereArgs: [dateStr],
      );
    }
  }

  static Future<int> _updateDailySpentMoney(
    DateTime date,
    double amount,
  ) async {
    final db = await database;
    final dateStr = _formatDate(date);

    // Check if entry exists for this date
    final existingEntries = await db.query(
      'daily_finances',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (existingEntries.isEmpty) {
      // Create new entry
      return await db.insert('daily_finances', {
        'date': dateStr,
        'gained_money': 0.0,
        'spent_money': amount,
      });
    } else {
      // Update existing entry
      final currentSpent = existingEntries.first['spent_money'] as double;
      return await db.update(
        'daily_finances',
        {'spent_money': currentSpent + amount},
        where: 'date = ?',
        whereArgs: [dateStr],
      );
    }
  }

  // Helper to format date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static Future<void> insertOperation(double amount, String type) async {
    final db = await database;
    await db.insert('daily_operations', {
      'amount': amount,
      'type': type,
      'date': DateTime.now().toIso8601String().substring(0, 10),
    });
  }

  static Future<List<Map<String, dynamic>>> getTodayOperations() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return await db.query(
      'daily_operations',
      where: 'date = ?',
      whereArgs: [today],
    );
  }

  static Future<void> archiveAndResetIfNewDay() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final ops = await db.query('daily_operations');
    if (ops.isEmpty) return;

    final lastDate = ops.first['date'];
    if (lastDate != today) {
      final incomeTotal = ops
          .where((e) => e['type'] == 'income')
          .fold(0.0, (sum, e) => sum + (e['amount'] as num));
      final spendTotal = ops
          .where((e) => e['type'] == 'spend')
          .fold(0.0, (sum, e) => sum + (e['amount'] as num));

      await db.insert('daily_operations_history', {
        'total_income': incomeTotal,
        'total_spend': spendTotal,
        'date': lastDate,
      });

      await db.delete('daily_operations');
    }
  }

  // Query operations
  static Future<List<Map<String, dynamic>>> getAllPurchasesWithItems() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT 
      p.id AS purchase_id,
      p.date,
      p.total_amount,
      COALESCE(b.name, '') AS buyer_name,
      f.name AS item_name,
      bi.price AS item_price,
      bi.weight AS item_weight,
      bi.count AS item_count,
      bi.total AS item_total

    FROM purchases p
    JOIN buyers b ON p.buyer_id = b.id
    LEFT JOIN bill_items bi ON bi.purchase_id = p.id
    LEFT JOIN fruits f ON f.id = bi.fruit_id

    ORDER BY p.date DESC, bi.id ASC
  ''');
  }

  static Future<List<Map<String, dynamic>>> getPurchasesByDate(
    DateTime date,
  ) async {
    final db = await database;
    final dateStr = _formatDate(date);

    return await db.rawQuery(
      '''
      SELECT p.id, p.date, p.total_amount, b.name as buyer_name
      FROM purchases p
      JOIN buyers b ON p.buyer_id = b.id
      WHERE date(p.date) = date(?)
      ORDER BY p.id DESC
    ''',
      [dateStr],
    );
  }

  static Future<List<Map<String, dynamic>>> getPurchasesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startDateStr = _formatDate(startDate);
    final endDateStr = _formatDate(endDate);

    return await db.rawQuery(
      '''
      SELECT p.id, p.date, p.total_amount, b.name as buyer_name
      FROM purchases p
      JOIN buyers b ON p.buyer_id = b.id
      WHERE date(p.date) BETWEEN date(?) AND date(?)
      ORDER BY p.date DESC
    ''',
      [startDateStr, endDateStr],
    );
  }

  static Future<List<Map<String, dynamic>>> getPurchasesByBuyer(
    String buyerName,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT p.id, p.date, p.total_amount, b.name as buyer_name
      FROM purchases p
      JOIN buyers b ON p.buyer_id = b.id
      WHERE b.name LIKE ?
      ORDER BY p.date DESC
    ''',
      ['%$buyerName%'],
    );
  }

  static Future<List<Map<String, dynamic>>> getPurchasesByFruit(
    String fruitName,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT DISTINCT p.id, p.date, p.total_amount, b.name as buyer_name
      FROM purchases p
      JOIN buyers b ON p.buyer_id = b.id
      JOIN bill_items bi ON bi.purchase_id = p.id
      JOIN fruits f ON bi.fruit_id = f.id
      WHERE f.name LIKE ?
      ORDER BY p.date DESC
    ''',
      ['%$fruitName%'],
    );
  }

  static Future<List<Map<String, dynamic>>> searchPurchases(
    String query,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT DISTINCT p.id, p.date, p.total_amount, b.name as buyer_name
      FROM purchases p
      JOIN buyers b ON p.buyer_id = b.id
      LEFT JOIN bill_items bi ON bi.purchase_id = p.id
      LEFT JOIN fruits f ON bi.fruit_id = f.id
      WHERE b.name LIKE ?
         OR f.name LIKE ?
         OR p.total_amount LIKE ?
      ORDER BY p.date DESC
    ''',
      ['%$query%', '%$query%', '%$query%'],
    );
  }

  static Future<List<Map<String, dynamic>>> getPurchaseDetails(
    int purchaseId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT bi.id, f.name, bi.price, bi.weight, bi.count, bi.total
      FROM bill_items bi
      JOIN fruits f ON bi.fruit_id = f.id
      WHERE bi.purchase_id = ?
    ''',
      [purchaseId],
    );
  }

  static Future<PurchaseEntity> getPurchaseEntity(int purchaseId) async {
    final db = await database;

    // Get purchase info
    final purchases = await db.query(
      'purchases',
      where: 'id = ?',
      whereArgs: [purchaseId],
    );

    if (purchases.isEmpty) {
      throw Exception('Purchase not found');
    }

    final purchase = purchases.first;
    final buyerId = purchase['buyer_id'] as int;

    // Get buyer info
    final buyers = await db.query(
      'buyers',
      where: 'id = ?',
      whereArgs: [buyerId],
    );

    final buyerName = buyers.first['name'] as String;

    // Get bill items
    final billItemsData = await getPurchaseDetails(purchaseId);
    final billItems =
        billItemsData
            .map(
              (item) => BillItemEntity(
                price: item['price'] as double,
                weight: item['weight'] as double,
                count: item['count'] as int,
                name: item['name'] as String,
                total: item['total'] as double,
                type: item['type'] as String,
              ),
            )
            .toList();

    return PurchaseEntity(
      bill: billItems,
      buyer: buyerName,
      total: purchase['total_amount'] as double,
    );
  }

  // New getter methods for better data access
  static Future<Map<String, dynamic>> getFruitById(int fruitId) async {
    final db = await database;
    final fruits = await db.query(
      'fruits',
      where: 'id = ?',
      whereArgs: [fruitId],
    );

    if (fruits.isEmpty) {
      throw Exception('Fruit not found');
    }

    return fruits.first;
  }

  static Future<Map<String, dynamic>> getBuyerById(int buyerId) async {
    final db = await database;
    final buyers = await db.query(
      'buyers',
      where: 'id = ?',
      whereArgs: [buyerId],
    );

    if (buyers.isEmpty) {
      throw Exception('Buyer not found');
    }

    return buyers.first;
  }

  // Get sales statistics
  static Future<Map<String, dynamic>> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final start = startDate ?? DateTime(today.year, today.month, 1);
    final end = endDate ?? DateTime(today.year, today.month + 1, 0);

    final startDateStr = _formatDate(start);
    final endDateStr = _formatDate(end);

    // Get total sales in date range
    final salesResult = await db.rawQuery(
      '''
      SELECT
        COUNT(*) as total_sales,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as average_sale
      FROM purchases
      WHERE date(date) BETWEEN date(?) AND date(?)
    ''',
      [startDateStr, endDateStr],
    );

    // Get top fruits by sales
    final topFruitsResult = await db.rawQuery(
      '''
      SELECT
        f.name,
        SUM(bi.total) as total_sales,
        SUM(bi.weight) as total_weight
      FROM bill_items bi
      JOIN fruits f ON bi.fruit_id = f.id
      JOIN purchases p ON bi.purchase_id = p.id
      WHERE date(p.date) BETWEEN date(?) AND date(?)
      GROUP BY f.id
      ORDER BY total_sales DESC
      LIMIT 5
    ''',
      [startDateStr, endDateStr],
    );

    // Get top buyers
    final topBuyersResult = await db.rawQuery(
      '''
      SELECT
        b.name,
        COUNT(p.id) as purchase_count,
        SUM(p.total_amount) as total_spent
      FROM purchases p
      JOIN buyers b ON p.buyer_id = b.id
      WHERE date(p.date) BETWEEN date(?) AND date(?)
      GROUP BY b.id
      ORDER BY total_spent DESC
      LIMIT 5
    ''',
      [startDateStr, endDateStr],
    );

    // Calculate profits
    final financesResult = await db.rawQuery(
      '''
      SELECT
        SUM(gained_money) as total_gained,
        SUM(spent_money) as total_spent
      FROM daily_finances
      WHERE date(date) BETWEEN date(?) AND date(?)
    ''',
      [startDateStr, endDateStr],
    );

    return {
      'period': {'start': startDateStr, 'end': endDateStr},
      'sales':
          salesResult.isNotEmpty
              ? salesResult.first
              : {'total_sales': 0, 'total_revenue': 0, 'average_sale': 0},
      'top_fruits': topFruitsResult,
      'top_buyers': topBuyersResult,
      'finances':
          financesResult.isNotEmpty
              ? financesResult.first
              : {'total_gained': 0, 'total_spent': 0},
    };
  }

  // Get financial report by date range
  static Future<List<Map<String, dynamic>>> getFinancialReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startDateStr = _formatDate(startDate);
    final endDateStr = _formatDate(endDate);

    return await db.rawQuery(
      '''
      SELECT
        date,
        gained_money,
        spent_money,
        (gained_money - spent_money) as net_profit
      FROM daily_finances
      WHERE date(date) BETWEEN date(?) AND date(?)
      ORDER BY date
    ''',
      [startDateStr, endDateStr],
    );
  }

  // Delete purchase and related bill items
  static Future<int> deletePurchase(int purchaseId) async {
    final db = await database;

    // Get purchase info first to update daily finances
    final purchases = await db.query(
      'purchases',
      where: 'id = ?',
      whereArgs: [purchaseId],
    );

    if (purchases.isEmpty) {
      return 0;
    }

    final purchase = purchases.first;
    final amount = purchase['total_amount'] as double;
    final dateStr = purchase['date'] as String;
    final date = DateTime.parse(dateStr);

    // Reduce gained money
    await _updateDailyGainedMoney(date, -amount);

    // The foreign key constraint will handle deletion of related bill items
    return await db.delete(
      'purchases',
      where: 'id = ?',
      whereArgs: [purchaseId],
    );
  }
}
