import 'menu_item.dart';

class OrderItem {
  final MenuItem menuItem;
  int quantity;
  String? specialInstructions;

  OrderItem({
    required this.menuItem,
    required this.quantity,
    this.specialInstructions,
  });

  double get totalPrice => menuItem.price * quantity;
}

class Order {
  final String id;
  final String tableNumber;
  final List<OrderItem> items;
  final DateTime createdAt;
  OrderStatus status;
  String? notes;

  Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.createdAt,
    this.status = OrderStatus.pending,
    this.notes,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      tableNumber: json['tableNumber'],
      items:
          (json['items'] as List)
              .map(
                (item) => OrderItem(
                  menuItem: MenuItem.fromJson(item['menuItem']),
                  quantity: item['quantity'],
                  specialInstructions: item['specialInstructions'],
                ),
              )
              .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
      ),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'items':
          items
              .map(
                (item) => {
                  'menuItem': item.menuItem.toJson(),
                  'quantity': item.quantity,
                  'specialInstructions': item.specialInstructions,
                },
              )
              .toList(),
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'notes': notes,
    };
  }
}

enum OrderStatus { pending, preparing, ready, served, completed, cancelled }
