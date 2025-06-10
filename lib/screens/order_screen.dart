import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/restaurant_models.dart' as models;
import 'billing_screen.dart';

class OrderScreen extends StatefulWidget {
  final models.Table table;
  final Function(models.Table) onOrderUpdate;

  const OrderScreen({
    super.key,
    required this.table,
    required this.onOrderUpdate,
  });

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late models.Table currentTable;
  List<models.MenuItem> menuItems = [];
  List<models.MenuItem> filteredItems = [];
  String selectedCategory = 'All';
  List<String> categories = [
    'All',
    'Starters',
    'Main Course',
    'Beverages',
    'Desserts',
  ];

  @override
  void initState() {
    super.initState();
    currentTable = widget.table;
    _initializeMenu();
    filteredItems = menuItems;
  }

  void _initializeMenu() {
    menuItems = [
      // Starters
      models.MenuItem(
        id: '1',
        name: 'Paneer Tikka',
        price: 280,
        category: 'Starters',
        image: '🧀',
      ),
      models.MenuItem(
        id: '2',
        name: 'Chicken Wings',
        price: 320,
        category: 'Starters',
        image: '🍗',
      ),
      models.MenuItem(
        id: '3',
        name: 'Spring Rolls',
        price: 180,
        category: 'Starters',
        image: '🥬',
      ),

      // Main Course
      models.MenuItem(
        id: '4',
        name: 'Butter Chicken',
        price: 380,
        category: 'Main Course',
        image: '🍛',
      ),
      models.MenuItem(
        id: '5',
        name: 'Biryani',
        price: 350,
        category: 'Main Course',
        image: '🍚',
      ),
      models.MenuItem(
        id: '6',
        name: 'Dal Makhani',
        price: 220,
        category: 'Main Course',
        image: '🍲',
      ),

      // Beverages
      models.MenuItem(
        id: '7',
        name: 'Mango Lassi',
        price: 120,
        category: 'Beverages',
        image: '🥤',
      ),
      models.MenuItem(
        id: '8',
        name: 'Masala Chai',
        price: 80,
        category: 'Beverages',
        image: '☕',
      ),
      models.MenuItem(
        id: '9',
        name: 'Fresh Lime',
        price: 90,
        category: 'Beverages',
        image: '🍋',
      ),

      // Desserts
      models.MenuItem(
        id: '10',
        name: 'Gulab Jamun',
        price: 140,
        category: 'Desserts',
        image: '🍯',
      ),
      models.MenuItem(
        id: '11',
        name: 'Ice Cream',
        price: 120,
        category: 'Desserts',
        image: '🍨',
      ),
    ];
  }

  void _filterItems(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredItems = menuItems;
      } else {
        filteredItems =
            menuItems.where((item) => item.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Table ${currentTable.number} - ${currentTable.customerName}',
        ),
        backgroundColor: Color(0xFFFF6B35),
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.receipt), onPressed: _showOrderSummary),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                String category = categories[index];
                bool isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () => _filterItems(category),
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFFFF6B35) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? Color(0xFFFF6B35) : Colors.grey[300]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return _buildMenuItemCard(filteredItems[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${currentTable.orders.length + currentTable.sentOrders.length} items',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Total: ₹${_calculateTotal()}',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed:
                  currentTable.orders.isNotEmpty ? _sendOrderToKitchen : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Send to Kitchen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(models.MenuItem item) {
    int quantity = _getItemQuantity(item.id);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item.image, style: TextStyle(fontSize: 24)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₹${item.price}',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (quantity > 0) ...[
              Row(
                children: [
                  IconButton(
                    onPressed: () => _removeItem(item),
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                  ),
                  Text(
                    quantity.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () => _addItem(item),
                    icon: Icon(Icons.add_circle, color: Color(0xFFFF6B35)),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => _addItem(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6B35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Add'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _getItemQuantity(String itemId) {
    return currentTable.orders.where((order) => order.itemId == itemId).length;
  }

  void _addItem(models.MenuItem item) {
    setState(() {
      currentTable.orders.add(
        models.OrderItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          itemId: item.id,
          itemName: item.name,
          price: item.price,
          quantity: 1,
        ),
      );
    });
    HapticFeedback.lightImpact();
  }

  void _removeItem(models.MenuItem item) {
    setState(() {
      int index = currentTable.orders.indexWhere(
        (order) => order.itemId == item.id,
      );
      if (index != -1) {
        currentTable.orders.removeAt(index);
      }
    });
    HapticFeedback.lightImpact();
  }

  int _calculateTotal() {
    return currentTable.orders.fold(0, (sum, order) => sum + order.price) +
        currentTable.sentOrders.fold(0, (sum, order) => sum + order.price);
  }

  void _showOrderSummary() {
    bool canEdit =
        currentTable.orderSentTime == null ||
        DateTime.now().difference(currentTable.orderSentTime!).inMinutes < 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Group current orders
        Map<String, List<models.OrderItem>> currentGroupedOrders = {};
        for (var order in currentTable.orders) {
          if (currentGroupedOrders.containsKey(order.itemName)) {
            currentGroupedOrders[order.itemName]!.add(order);
          } else {
            currentGroupedOrders[order.itemName] = [order];
          }
        }

        // Group sent orders
        Map<String, List<models.OrderItem>> sentGroupedOrders = {};
        for (var order in currentTable.sentOrders) {
          if (sentGroupedOrders.containsKey(order.itemName)) {
            sentGroupedOrders[order.itemName]!.add(order);
          } else {
            sentGroupedOrders[order.itemName] = [order];
          }
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (canEdit && currentTable.orders.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditOrderDialog();
                      },
                      icon: Icon(Icons.edit, size: 16),
                      label: Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
              if (!canEdit && currentTable.orderSentTime != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Edit time expired (1 min limit)',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 20),
              if (currentTable.sentOrders.isNotEmpty) ...[
                Text(
                  'Sent to Kitchen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                ...sentGroupedOrders.entries.map((entry) {
                  String itemName = entry.key;
                  List<models.OrderItem> orders = entry.value;
                  return ListTile(
                    title: Text(itemName),
                    subtitle: Text('₹${orders.first.price} each'),
                    trailing: Text(
                      '${orders.length} x ₹${orders.first.price * orders.length}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                Divider(height: 24),
              ],
              if (currentTable.orders.isNotEmpty) ...[
                Text(
                  'Current Order',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                ...currentGroupedOrders.entries.map((entry) {
                  String itemName = entry.key;
                  List<models.OrderItem> orders = entry.value;
                  return ListTile(
                    title: Text(itemName),
                    subtitle: Text('₹${orders.first.price} each'),
                    trailing: Text(
                      '${orders.length} x ₹${orders.first.price * orders.length}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ],
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${_calculateTotal()}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (currentTable.orders.isNotEmpty ||
                              currentTable.sentOrders.isNotEmpty)
                          ? _goToBilling
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Map<String, List<models.OrderItem>> groupedOrders = {};
            for (var order in currentTable.orders) {
              if (groupedOrders.containsKey(order.itemName)) {
                groupedOrders[order.itemName]!.add(order);
              } else {
                groupedOrders[order.itemName] = [order];
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('Edit Order'),
              content: Container(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: groupedOrders.length,
                  itemBuilder: (context, index) {
                    String itemName = groupedOrders.keys.elementAt(index);
                    List<models.OrderItem> orders = groupedOrders[itemName]!;
                    return ListTile(
                      title: Text(itemName),
                      subtitle: Text('₹${orders.first.price} each'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                this.setState(() {
                                  int orderIndex = currentTable.orders
                                      .indexWhere(
                                        (order) => order.itemName == itemName,
                                      );
                                  if (orderIndex != -1) {
                                    currentTable.orders.removeAt(orderIndex);
                                  }
                                });
                              });
                            },
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                          ),
                          Text(
                            orders.length.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                this.setState(() {
                                  models.MenuItem menuItem = menuItems
                                      .firstWhere(
                                        (item) => item.name == itemName,
                                      );
                                  currentTable.orders.add(
                                    models.OrderItem(
                                      id:
                                          DateTime.now().millisecondsSinceEpoch
                                              .toString(),
                                      itemId: menuItem.id,
                                      itemName: menuItem.name,
                                      price: menuItem.price,
                                      quantity: 1,
                                    ),
                                  );
                                });
                              });
                            },
                            icon: Icon(
                              Icons.add_circle,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _sendOrderToKitchen() {
    setState(() {
      currentTable = currentTable.copyWith(
        orderSentTime: DateTime.now(),
        sentOrders: [...currentTable.sentOrders, ...currentTable.orders],
        orders: [], // Reset current orders after sending to kitchen
      );
    });
    widget.onOrderUpdate(currentTable);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order sent to kitchen!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _goToBilling() {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BillingScreen(
              table: currentTable,
              onBillingComplete: (table) {
                widget.onOrderUpdate(table);
                Navigator.pop(context); // Go back to home screen
              },
            ),
      ),
    );
  }
}
