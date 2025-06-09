import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/cart_model.dart';

class MenuScreen extends StatefulWidget {
  final TableModel table;

  const MenuScreen({Key? key, required this.table}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Cart _cart;
  bool _isCartVisible = false;
  bool _hasOrderedItems = false;

  // TODO: Replace with actual menu data from backend
  final List<Map<String, dynamic>> _menuItems = [
    {
      'id': '1',
      'name': 'Margherita Pizza',
      'description': 'Classic tomato and mozzarella pizza',
      'price': 12.99,
      'category': 'Main Course',
    },
    {
      'id': '2',
      'name': 'Caesar Salad',
      'description': 'Fresh romaine lettuce with Caesar dressing',
      'price': 8.99,
      'category': 'Appetizers',
    },
    {
      'id': '3',
      'name': 'Grilled Salmon',
      'description': 'Fresh salmon with herbs and lemon',
      'price': 24.99,
      'category': 'Main Course',
    },
    {
      'id': '4',
      'name': 'Chocolate Cake',
      'description': 'Rich chocolate cake with ganache',
      'price': 7.99,
      'category': 'Desserts',
    },
    {
      'id': '5',
      'name': 'Mojito',
      'description': 'Classic mint and lime cocktail',
      'price': 9.99,
      'category': 'Beverages',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cart = Cart(tableId: widget.table.id);
  }

  void _addToCart(Map<String, dynamic> menuItem) {
    setState(() {
      _cart.addItem(
        CartItem(
          id: menuItem['id'],
          name: menuItem['name'],
          price: menuItem['price'],
        ),
      );
      if (!_hasOrderedItems) {
        _hasOrderedItems = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${menuItem['name']} added to cart'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showCart() {
    setState(() {
      _isCartVisible = true;
    });
  }

  void _hideCart() {
    setState(() {
      _isCartVisible = false;
    });
  }

  void _updateQuantity(CartItem item, int quantity) {
    setState(() {
      _cart.updateQuantity(item.id, quantity);
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cart.removeItem(item.id);
    });
  }

  void _sendOrderToKitchen() {
    // TODO: Implement sending order to kitchen
    setState(() {
      _cart.isOrderSent = true;
      _isCartVisible = false;
    });

    // Update the table's orders in the parent screen
    if (Navigator.canPop(context)) {
      Navigator.pop(context, _cart);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order sent to kitchen'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${widget.table.tableNumber} - Menu'),
        backgroundColor: Colors.orange,
        actions: [
          if (_hasOrderedItems)
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () {
                // TODO: Show order statistics
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        item['description'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${item['price'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle),
                    color: Colors.orange,
                    iconSize: 32,
                    onPressed: () => _addToCart(item),
                  ),
                ),
              );
            },
          ),
          if (_isCartVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cart',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _hideCart,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cart.items.length,
                        itemBuilder: (context, index) {
                          final item = _cart.items[index];
                          return ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed:
                                      () => _updateQuantity(
                                        item,
                                        item.quantity - 1,
                                      ),
                                ),
                                Text(
                                  item.quantity.toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed:
                                      () => _updateQuantity(
                                        item,
                                        item.quantity + 1,
                                      ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _removeItem(item),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${_cart.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _cart.items.isNotEmpty
                                      ? _sendOrderToKitchen
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Send to Kitchen',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton:
          !_isCartVisible
              ? FloatingActionButton.extended(
                onPressed: _showCart,
                backgroundColor: Colors.orange,
                icon: const Icon(Icons.shopping_cart),
                label: Text('Cart (${_cart.items.length})'),
              )
              : null,
    );
  }
}
