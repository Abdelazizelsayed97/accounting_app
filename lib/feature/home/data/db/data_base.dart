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
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              'ALTER TABLE bill_items ADD COLUMN buyer_id INTEGER REFERENCES buyers(id)',
            );
          }
        },

        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
    CREATE TABLE IF NOT EXISTS daily_operations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL,
  type TEXT CHECK(type IN ('income', 'spend')) NOT NULL,
  date TEXT NOT NULL UNIQUE
);
        ''');
          await db.execute('''
CREATE TABLE IF NOT EXISTS daily_operations_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  total_income REAL,
  total_spend REAL,
  date TEXT NOT NULL,
  FOREIGN KEY (date) REFERENCES daily_operations(date) ON DELETE CASCADE
);
        ''');
          await db.execute('''
  CREATE TABLE FARMERS_ENTITY (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
  );
''');

          await db.execute('''
  CREATE TABLE FARMERS (
    farmers_entity_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
 
    FOREIGN KEY (farmers_entity_id) REFERENCES FARMERS_ENTITY(id) ON DELETE CASCADE
  );
''');
          await db.execute('''
  CREATE TABLE suppliers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
          ''');
          await db.execute('''
  CREATE TABLE buyers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
''');

          await db.execute('''
  CREATE TABLE fruits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
''');

          await db.execute('''
  CREATE TABLE supplier_purchases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  supplier_id INTEGER NOT NULL,
  total_amount REAL NOT NULL,
  date TEXT DEFAULT CURRENT_TIMESTAMP,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE
  );
''');

          await db.execute('''
CREATE TABLE supplier_bill_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  purchase_id INTEGER NOT NULL,
  fruit_id INTEGER NOT NULL,
  buyer_id INTEGER NOT NULL,
  price REAL NOT NULL,
  weight REAL NOT NULL,
  tax REAL NOT NULL,
  delivery REAL NOT NULL,
  services REAL NOT NULL,
  count INTEGER DEFAULT 0,
  total REAL GENERATED ALWAYS AS (price * weight) STORED,
  FOREIGN KEY (purchase_id) REFERENCES supplier_purchases(id) ON DELETE CASCADE,
  FOREIGN KEY (fruit_id) REFERENCES fruits(id) ON DELETE RESTRICT,
  FOREIGN KEY (buyer_id) REFERENCES buyers(id) ON DELETE RESTRICT
);
''');
          await db.execute('''
          CREATE TABLE buyer_purchases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  buyer_id INTEGER NOT NULL,
  total_amount REAL NOT NULL,
  date TEXT DEFAULT CURRENT_TIMESTAMP,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (buyer_id) REFERENCES buyers(id) ON DELETE CASCADE
);
          ''');
          await db.execute('''
          CREATE TABLE buyer_bill_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  purchase_id INTEGER NOT NULL,
  fruit_id INTEGER NOT NULL,
  price REAL NOT NULL,
  weight REAL NOT NULL,
  count INTEGER DEFAULT 0,
  total REAL GENERATED ALWAYS AS (price * weight) STORED,
  FOREIGN KEY (purchase_id) REFERENCES buyer_purchases(id) ON DELETE CASCADE,
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
          // Add `buyer_id` column to `bill_items` if not already present
          // Only run this if bill_items was created before buyer_id was added

          // Create indexes (safe from duplication)
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_supplier_purchases_date ON supplier_purchases(date);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_supplier_purchases_supplier_id ON supplier_purchases(supplier_id);',
          );

          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_buyer_purchases_date ON buyer_purchases(date);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_buyer_purchases_buyer_id ON buyer_purchases(buyer_id);',
          );

          // Indexes for supplier_bill_items
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_supplier_bill_items_purchase_id ON supplier_bill_items(purchase_id);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_supplier_bill_items_fruit_id ON supplier_bill_items(fruit_id);',
          );

          // Indexes for buyer_bill_items
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_buyer_bill_items_purchase_id ON buyer_bill_items(purchase_id);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_buyer_bill_items_fruit_id ON buyer_bill_items(fruit_id);',
          );

          // Buyer and Supplier indexes
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_suppliers_name ON suppliers(name);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_buyers_name ON buyers(name);',
          );

          // Finance tracking
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_daily_finances_date ON daily_finances(date);',
          );
        },
      ),
    );
  }

  // Purchase operations
  static Future<int> insertSupplierPurchase(PurchaseEntity purchase) async {
    final db = await database;

    // 1. Insert the supplier purchase header
    final supplierId = await _getSupplierId(purchase.ownerName);
    final purchaseId = await db.insert('supplier_purchases', {
      'supplier_id': supplierId,
      'total_amount': purchase.total,
    });

    // 2. Insert bill items
    for (final item in purchase.bill) {
      final fruitId = await _getFruitId(item.fruitName);
      final buyerId = await _getBuyerId(item.customerName);
      await db.insert('supplier_bill_items', {
        'purchase_id': purchaseId,
        'fruit_id': fruitId,
        'price': item.price,
        'weight': item.weight,
        'count': item.count,
        'buyer_id': buyerId,
        'tax': item.tax,
        'delivery': item.delivery,
        'services': item.services,
      });
    }

    // 3. Optionally update any daily report
    await _updateDailyGainedMoney(DateTime.now(), purchase.total.toDouble());

    return purchaseId;
  }

  static Future<int> insertBuyerPurchase(PurchaseEntity purchase) async {
    final db = await database;

    // 1. Insert the buyer purchase header
    final buyerId = await _getBuyerId(purchase.ownerName);
    final purchaseId = await db.insert('buyer_purchases', {
      'buyer_id': buyerId,
      'total_amount': purchase.total,
    });

    // 2. Insert bill items
    for (final item in purchase.bill) {
      final fruitId = await _getFruitId(item.fruitName);
      await db.insert('buyer_bill_items', {
        'purchase_id': purchaseId,
        'fruit_id': fruitId,
        'price': item.price,
        'weight': item.weight,
        'count': item.count,
      });
    }

    // 3. Optionally update any daily report
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
  static Future<int> insertFruit(String name) async {
    final db = await database;

    return await db.insert('fruits', {'name': name});
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
      print('found buyer');
      return buyers.first['id'] as int;
    } else {
      // Create the buyer if not exists
      return await insertBuyer(buyerName);
    }
  }

  static Future<int> _getSupplierId(String buyerName) async {
    final db = await database;
    final suppliers = await db.query(
      'suppliers',
      where: 'name = ?',
      whereArgs: [buyerName],
    );

    if (suppliers.isNotEmpty) {
      return suppliers.first['id'] as int;
    } else {
      return await insertSupplier(buyerName);
    }
  }

  // Buyer operations
  static Future<int> insertSupplier(String name) async {
    final db = await database;
    return await db.insert('suppliers', {'name': name});
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
      return insertFruit(fruitName);
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
  static Future<List<Map<String, dynamic>>>
  getAllSuppliersPurchasesWithItems() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT
      sp.id AS purchase_id,
      sp.date,
      sp.total_amount,
      s.id AS supplier_id,
      COALESCE(s.name, '') AS supplier_name,
      sbi.id AS bill_item_id,
      f.id AS fruit_id,
      f.name AS fruit_name,
      b.id AS buyer_id,
      b.name AS buyer_name,
      sbi.price AS item_price,
      sbi.weight AS item_weight,
      sbi.count AS item_count,
      sbi.total AS item_total,
      sbi.tax AS item_tax,
      sbi.delivery AS item_delivery,
      sbi.services AS item_services

    FROM supplier_purchases sp
    JOIN suppliers s ON sp.supplier_id = s.id
    LEFT JOIN supplier_bill_items sbi ON sbi.purchase_id = sp.id
    LEFT JOIN fruits f ON f.id = sbi.fruit_id
    LEFT JOIN buyers b ON b.id = sbi.buyer_id
    ORDER BY sp.date DESC, sbi.id ASC;
  ''');
  }

  static Future<List<Map<String, dynamic>>>
  getAllBuyerPurchasesWithItems() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT
      bp.id AS purchase_id,
      bp.date,
      bp.total_amount,

      b.id AS buyer_id,
      COALESCE(b.name, '') AS buyer_name,

      bbi.id AS bill_item_id,
      f.id AS fruit_id,
      f.name AS fruit_name,

      bbi.price AS item_price,
      bbi.weight AS item_weight,
      bbi.count AS item_count,
      bbi.total AS item_total

    FROM buyer_purchases bp
      JOIN buyers b ON bp.buyer_id = b.id
      LEFT JOIN buyer_bill_items bbi ON bbi.purchase_id = bp.id
      LEFT JOIN fruits f ON f.id = bbi.fruit_id

    ORDER BY bp.date DESC, bbi.id ASC;
  ''');
  }

  static Future<List<Map<String, dynamic>>> getPurchasesByDate(
    DateTime date,
  ) async {
    final db = await database;
    final dateStr = _formatDate(date);

    return await db.rawQuery(
      '''
    SELECT 
      p.id, 
      p.date, 
      p.total_amount, 
      s.name AS supplier_name
    FROM supplier_purchases p
    JOIN suppliers s ON p.supplier_id = s.id
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
      FROM supplier_purchases p
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
      FROM supplier_purchases p
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
      FROM supplier_purchases p
      JOIN buyers b ON p.buyer_id = b.id
      JOIN bill_items bi ON bi.purchase_id = p.id
      JOIN fruits f ON bi.fruit_id = f.id
      WHERE f.name LIKE ?
      ORDER BY p.date DESC
    ''',
      ['%$fruitName%'],
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
      'supplier_purchases',
      where: 'id = ?',
      whereArgs: [purchaseId],
    );

    if (purchases.isEmpty) {
      throw Exception('Purchase not found');
    }

    final purchase = purchases.first;
    final buyerId = purchase['buyer_id'] as int?;

    // Get buyer info
    String buyerName = 'غير معروف';
    if (buyerId != null) {
      final buyers = await db.query(
        'buyers',
        where: 'id = ?',
        whereArgs: [buyerId],
      );
      if (buyers.isNotEmpty) {
        buyerName = buyers.first['name'] as String;
      }
    }

    // Get bill items
    final billItemsData = await getPurchaseDetails(purchaseId);
    final billItems =
        billItemsData
            .map(
              (item) => BillItemEntity(
                price: (item['price'] as num?)?.toDouble() ?? 0.0,
                weight: (item['weight'] as num?)?.toDouble() ?? 0.0,
                count: item['count'] as int? ?? 0,
                customerName: item['name'] as String? ?? '',
                total: (item['total'] as num?)?.toDouble() ?? 0.0,
                type: item['type'] as String? ?? '',
                fruitName: item["item_name"] as String,
                tax: item['tax'] as String,
                delivery: item['delivery'] as String,
                services: item['services'] as String,
              ),
            )
            .toList();

    return PurchaseEntity(
      bill: billItems,
      ownerName: buyerName,
      total: (purchase['total_amount'] as num?)?.toDouble() ?? 0.0,
      date: purchase["date"].toString(),
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
