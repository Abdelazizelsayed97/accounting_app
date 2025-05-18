class ImportsBillItemEntity {
  final double price;
  final double weight;
  final int count;
  final String fruitName;
  final String customerName; // <-- NEW
  final double total;
  final String type;
  final String tax; // <-- NEW
  final String delivery; // <-- NEW
  final String services;

  ImportsBillItemEntity({
    required this.price,
    required this.weight,
    required this.count,
    required this.fruitName,
    required this.customerName,
    required this.total,
    required this.type,
    required this.tax,
    required this.delivery,
    required this.services,
  });

  Map<String, dynamic> toMap() => {
    'price': price,
    'weight': weight,
    'count': count,
    'fruit_name': fruitName,
    'customer_name': customerName,
    'total': total,
    'type': type,
    'tax': tax,
    'delivery': delivery,
    'services': services,
  };

  factory ImportsBillItemEntity.fromMap(Map<String, dynamic> map) {
    return ImportsBillItemEntity(
      price: map['price']?.toDouble() ?? 0.0,
      weight: map['weight']?.toDouble() ?? 0.0,
      count: map['count'] ?? 0,
      fruitName: map['fruit_name'] ?? '',
      customerName: map['customer_name'] ?? '',
      total: map['total']?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      tax: map['tax'],
      delivery: map['delivery'],
      services: map['services'],
    );
  }
}

class ImportsEntity {
  final List<ImportsBillItemEntity> bill;
  final String ownerName;
  final double total;

  ImportsEntity({
    required this.bill,
    required this.ownerName,
    required this.total,
  });

  Map<String, dynamic> toMap() => {
    'bill': bill.map((e) => e.toMap()).toList(),
    'owner_name': ownerName,
    'total': total,
  };

  factory ImportsEntity.fromMap(Map<String, dynamic> map) {
    return ImportsEntity(
      bill:
          map['bill'] != null
              ? List<ImportsBillItemEntity>.from(
                map['bill'].map((x) => ImportsBillItemEntity.fromMap(x)),
              )
              : [],
      ownerName: map['owner_name'] ?? '',
      total: map['total_amount']?.toDouble() ?? 0.0,
    );
  }
}
