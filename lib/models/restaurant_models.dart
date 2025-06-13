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
  final int tip;

  Table({
    required this.number,
    required this.status,
    required this.customerName,
    required this.phoneNumber,
    required this.guestCount,
    required this.orders,
    this.sentOrders = const [],
    this.orderSentTime,
    this.tip = 0,
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
    int? tip,
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
      tip: tip ?? this.tip,
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
  final DateTime sentTime;

  OrderItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.quantity,
    required this.sentTime,
  });

  OrderItem copyWith({
    String? id,
    String? itemId,
    String? itemName,
    int? price,
    int? quantity,
    DateTime? sentTime,
  }) {
    return OrderItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      sentTime: sentTime ?? this.sentTime,
    );
  }
}
