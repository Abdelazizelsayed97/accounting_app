/*
*   // Get sales statistics
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
*/

/*
*           await db.execute('''
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
 CREATE TABLE purchases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  supplier_id INTEGER NOT NULL,
  total_amount REAL NOT NULL,
  date TEXT DEFAULT CURRENT_TIMESTAMP,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE
);
''');

          await db.execute('''
CREATE TABLE bill_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  purchase_id INTEGER NOT NULL,
  fruit_id INTEGER NOT NULL,
  buyer_id INTEGER, -- Nullable in case it's not assigned yet
  price REAL NOT NULL,
  weight REAL NOT NULL,
  count INTEGER DEFAULT 0,
  total REAL GENERATED ALWAYS AS (price * weight) STORED,
  FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
  FOREIGN KEY (fruit_id) REFERENCES fruits(id) ON DELETE RESTRICT,
  FOREIGN KEY (buyer_id) REFERENCES buyers(id) ON DELETE SET NULL
);
''');
*/
