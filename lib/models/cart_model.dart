class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  String? notes;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.notes,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      notes: json['notes'],
    );
  }
}

class Cart {
  final String tableId;
  final List<CartItem> items;
  final DateTime createdAt;
  bool isOrderSent;

  Cart({
    required this.tableId,
    List<CartItem>? items,
    DateTime? createdAt,
    this.isOrderSent = false,
  }) : items = items ?? [],
       createdAt = createdAt ?? DateTime.now();

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(CartItem item) {
    final existingItemIndex = items.indexWhere(
      (element) => element.id == item.id,
    );
    if (existingItemIndex != -1) {
      items[existingItemIndex].quantity += item.quantity;
    } else {
      items.add(item);
    }
  }

  void removeItem(String itemId) {
    items.removeWhere((item) => item.id == itemId);
  }

  void updateQuantity(String itemId, int quantity) {
    final item = items.firstWhere((item) => item.id == itemId);
    item.quantity = quantity;
    if (quantity <= 0) {
      removeItem(itemId);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isOrderSent': isOrderSent,
    };
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      tableId: json['tableId'],
      items:
          (json['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      isOrderSent: json['isOrderSent'],
    );
  }
}
