class BillItemEntity {
  final double price;
  final double weight;
  final int count;
  final String fruitName;
  final String customerName; // <-- NEW
  final double total;
  final String type;

  BillItemEntity({
    required this.price,
    required this.weight,
    required this.count,
    required this.fruitName,
    required this.customerName,
    required this.total,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
    'price': price,
    'weight': weight,
    'count': count,
    'fruit_name': fruitName,
    'customer_name': customerName,
    'total': total,
    'type': type,
  };

  factory BillItemEntity.fromMap(Map<String, dynamic> map) {
    return BillItemEntity(
      price: map['price']?.toDouble() ?? 0.0,
      weight: map['weight']?.toDouble() ?? 0.0,
      count: map['count'] ?? 0,
      fruitName: map['fruit_name'] ?? '',
      customerName: map['customer_name'] ?? '',
      total: map['total']?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
    );
  }
}

class PurchaseEntity {
  final List<BillItemEntity> bill;
  final String ownerName;
  final double total;

  PurchaseEntity({
    required this.bill,
    required this.ownerName,
    required this.total,
  });

  Map<String, dynamic> toMap() => {
    'bill': bill.map((e) => e.toMap()).toList(),
    'owner_name': ownerName,
    'total': total,
  };

  factory PurchaseEntity.fromMap(Map<String, dynamic> map) {
    return PurchaseEntity(
      bill:
          map['bill'] != null
              ? List<BillItemEntity>.from(
                map['bill'].map((x) => BillItemEntity.fromMap(x)),
              )
              : [],
      ownerName: map['owner_name'] ?? '',
      total: map['total_amount']?.toDouble() ?? 0.0,
    );
  }
}
