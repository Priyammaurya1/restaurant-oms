enum TableStatus { empty, occupied, reserved }

class Table {
  final int number;
  final TableStatus status;
  final String customerName;
  final String phoneNumber;
  final int guestCount;
  final List<OrderItem> orders;
  final List<OrderItem> sentOrders;
  final DateTime? orderSentTime;

  Table({
    required this.number,
    required this.status,
    required this.customerName,
    required this.phoneNumber,
    required this.guestCount,
    required this.orders,
    this.sentOrders = const [],
    this.orderSentTime,
  });

  Table copyWith({
    int? number,
    TableStatus? status,
    String? customerName,
    String? phoneNumber,
    int? guestCount,
    List<OrderItem>? orders,
    List<OrderItem>? sentOrders,
    DateTime? orderSentTime,
  }) {
    return Table(
      number: number ?? this.number,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      guestCount: guestCount ?? this.guestCount,
      orders: orders ?? this.orders,
      sentOrders: sentOrders ?? this.sentOrders,
      orderSentTime: orderSentTime ?? this.orderSentTime,
    );
  }
}

class MenuItem {
  final String id;
  final String name;
  final int price;
  final String category;
  final String image;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
  });
}

class OrderItem {
  final String id;
  final String itemId;
  final String itemName;
  final int price;
  final int quantity;

  OrderItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.quantity,
  });
}
