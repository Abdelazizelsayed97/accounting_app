class BillItemEntity {
  double price;
  double weight;
  int count;
  String name;
  double total;

  BillItemEntity({
    required this.price,
    required this.weight,
    required this.count,
    required this.name,
  }) : total = price * weight * count;

  Map<String, dynamic> toMap() => {
    'price': price,
    'weight': weight,
    'count': count,
    'name': name,
    'total': total,
  };

  factory BillItemEntity.fromMap(Map<String, dynamic> map) {
    return BillItemEntity(
      price: map['price'],
      weight: map['weight'],
      count: map['count'],
      name: map['name'],
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
