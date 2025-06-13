import 'package:flutter/material.dart';
import '../models/restaurant_models.dart' as models;
import 'billing_screen.dart';

class OrderScreen extends StatefulWidget {
  final models.Table table;
  final Function(models.Table) onOrderUpdate;
  final VoidCallback onOrderComplete;
  final Function(int) onTableReset;

  const OrderScreen({
    Key? key,
    required this.table,
    required this.onOrderUpdate,
    required this.onOrderComplete,
    required this.onTableReset,
  }) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final List<models.OrderItem> _cartItems = [];
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _cartItems.addAll(widget.table.orders);
    _calculateTotal();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    _totalAmount = _cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  void _addToCart(models.OrderItem item) {
    setState(() {
      final existingItemIndex = _cartItems.indexWhere(
        (cartItem) => cartItem.itemId == item.itemId,
      );

      if (existingItemIndex == -1) {
        _cartItems.add(item);
      } else {
        // Create a new OrderItem with updated quantity
        final existingItem = _cartItems[existingItemIndex];
        _cartItems[existingItemIndex] = models.OrderItem(
          id: existingItem.id,
          itemId: existingItem.itemId,
          itemName: existingItem.itemName,
          price: existingItem.price,
          quantity: existingItem.quantity + 1,
          sentTime: existingItem.sentTime,
        );
      }
      _calculateTotal();
    });
  }

  void _removeFromCart(models.OrderItem item) {
    setState(() {
      final existingItemIndex = _cartItems.indexWhere(
        (cartItem) => cartItem.itemId == item.itemId,
      );

      if (existingItemIndex != -1) {
        final existingItem = _cartItems[existingItemIndex];
        if (existingItem.quantity > 1) {
          // Create a new OrderItem with decreased quantity
          _cartItems[existingItemIndex] = models.OrderItem(
            id: existingItem.id,
            itemId: existingItem.itemId,
            itemName: existingItem.itemName,
            price: existingItem.price,
            quantity: existingItem.quantity - 1,
            sentTime: existingItem.sentTime,
          );
        } else {
          _cartItems.removeAt(existingItemIndex);
        }
        _calculateTotal();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Table ${widget.table.number}',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.receipt_long, color: Color(0xFF1A1A1A)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BillingScreen(
                        table: widget.table,
                        onOrderComplete: widget.onOrderComplete,
                        onTableReset: widget.onTableReset,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.table.customerName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${widget.table.guestCount} Guests',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xFF666666),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Order started ${_getTimeAgo(widget.table.orderSentTime ?? DateTime.now())}',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Menu Items',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.5,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: _getMenuItems().length,
                              itemBuilder: (context, index) {
                                final item = _getMenuItems()[index];
                                return _buildMenuItemCard(item);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, color: Colors.grey.withOpacity(0.2)),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Order',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child:
                                _cartItems.isEmpty
                                    ? Center(
                                      child: Text(
                                        'No items in cart',
                                        style: TextStyle(
                                          color: Color(0xFF666666),
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                    : ListView.builder(
                                      itemCount: _cartItems.length,
                                      itemBuilder: (context, index) {
                                        final item = _cartItems[index];
                                        return _buildCartItemCard(item);
                                      },
                                    ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Amount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    Text(
                                      '₹${_totalAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Update the table's orders
                                      final updatedTable = widget.table
                                          .copyWith(
                                            orders: _cartItems,
                                            orderSentTime: DateTime.now(),
                                          );
                                      widget.onOrderUpdate(updatedTable);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFF6B35),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Send Order',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(models.OrderItem item) {
    return GestureDetector(
      onTap: () => _addToCart(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 32,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₹${item.price}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(models.OrderItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '₹${item.price}',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: Color(0xFFFF6B35),
                ),
                onPressed: () => _removeFromCart(item),
              ),
              Text(
                '${item.quantity}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Color(0xFFFF6B35)),
                onPressed: () => _addToCart(item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<models.OrderItem> _getMenuItems() {
    // This would typically come from your menu data
    return [
      models.OrderItem(
        id: '1',
        itemId: '1',
        itemName: 'Butter Chicken',
        price: 380,
        quantity: 1,
        sentTime: DateTime.now(),
      ),
      models.OrderItem(
        id: '2',
        itemId: '2',
        itemName: 'Paneer Tikka',
        price: 280,
        quantity: 1,
        sentTime: DateTime.now(),
      ),
      models.OrderItem(
        id: '3',
        itemId: '3',
        itemName: 'Biryani',
        price: 350,
        quantity: 1,
        sentTime: DateTime.now(),
      ),
      models.OrderItem(
        id: '4',
        itemId: '4',
        itemName: 'Dal Makhani',
        price: 220,
        quantity: 1,
        sentTime: DateTime.now(),
      ),
      models.OrderItem(
        id: '5',
        itemId: '5',
        itemName: 'Naan',
        price: 40,
        quantity: 1,
        sentTime: DateTime.now(),
      ),
      models.OrderItem(
        id: '6',
        itemId: '6',
        itemName: 'Masala Chai',
        price: 80,
        quantity: 1,
        sentTime: DateTime.now(),
      ),
    ];
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
