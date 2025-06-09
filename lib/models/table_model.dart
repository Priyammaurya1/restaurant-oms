enum TableStatus { available, occupied, reserved }

class TableModel {
  final String id;
  final String tableNumber;
  TableStatus status;
  String? customerName;
  String? customerPhone;
  int? numberOfGuests;
  DateTime? occupiedAt;

  TableModel({
    required this.id,
    required this.tableNumber,
    this.status = TableStatus.available,
    this.customerName,
    this.customerPhone,
    this.numberOfGuests,
    this.occupiedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'status': status.toString(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'numberOfGuests': numberOfGuests,
      'occupiedAt': occupiedAt?.toIso8601String(),
    };
  }

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      tableNumber: json['tableNumber'],
      status: TableStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => TableStatus.available,
      ),
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      numberOfGuests: json['numberOfGuests'],
      occupiedAt:
          json['occupiedAt'] != null
              ? DateTime.parse(json['occupiedAt'])
              : null,
    );
  }
}
