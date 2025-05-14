class BillItemEntity {
  final double price;
  final double weight;
  final int count;
  final String name;
  final double total;
  final String type;

  BillItemEntity({
    required this.price,
    required this.weight,
    required this.count,
    required this.name,
    required this.total,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
    'price': price,
    'weight': weight,
    'count': count,
    'name': name,
    'total': total,
    'type': type,
  };

  factory BillItemEntity.fromMap(Map<String, dynamic> map) {
    return BillItemEntity(
      price: map['price']?.toDouble() ?? 0.0,
      weight: map['weight']?.toDouble() ?? 0.0,
      count: map['count'] ?? 0,
      name: map['fruit_name'] ?? '',
      total: map['total']?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
    );
  }
}

class PurchaseEntity {
  final List<BillItemEntity> bill;
  final String buyer;
  final double total;

  PurchaseEntity({
    required this.bill,
    required this.buyer,
    required this.total,
  });

  Map<String, dynamic> toMap() => {
    'bill': bill.map((e) => e.toMap()).toList(),
    'buyer': buyer,
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
      buyer: map['buyer_name'],
      total: map['total_amount'],
    );
  }
}
