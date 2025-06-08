import 'dart:async';

import 'package:flutter/material.dart';

// Data Models
class Customer {
  final String name;
  final String phone;
  final int guests;

  Customer({required this.name, required this.phone, required this.guests});
}

class FoodItem {
  final String name;
  final double price;
  final String category;

  FoodItem({required this.name, required this.price, required this.category});
}

enum OrderStatus {
  pending,    // Just added to table
  sent,       // Sent to kitchen
  preparing,  // Being prepared in kitchen
  ready,      // Ready to serve
  served,     // Served to table
  cancelled   // Cancelled order
}

class OrderItem {
  final FoodItem foodItem;
  int quantity;
  final DateTime addedTime;
  bool isEditable;
  Timer? editTimer;
  OrderStatus status;
  String? specialInstructions;

  OrderItem({
    required this.foodItem, 
    this.quantity = 1, 
    required this.addedTime,
    this.isEditable = true,
    this.status = OrderStatus.pending,
    this.specialInstructions,
  });

  void startEditTimer(VoidCallback onTimerComplete) {
    editTimer?.cancel();
    editTimer = Timer(const Duration(minutes: 1), () {
      isEditable = false;
      onTimerComplete();
    });
  }

  void cancelEditTimer() {
    editTimer?.cancel();
  }
}

class TableOrder {
  final int tableNumber;
  Customer? customer;
  List<OrderItem> orders;
  bool isCompleted;
  DateTime? orderStartTime;
  DateTime? lastOrderTime;
  String? specialRequests;
  double? tip;
  String? waiterName;

  TableOrder({required this.tableNumber}) 
    : orders = [],
      isCompleted = false;

  double get totalAmount {
    double subtotal = orders.fold(0, (sum, item) => sum + (item.foodItem.price * item.quantity));
    double tax = subtotal * 0.18; // 18% tax
    double serviceCharge = subtotal * 0.10; // 10% service charge
    return subtotal + tax + serviceCharge + (tip ?? 0);
  }

  double get subtotal {
    return orders.fold(0, (sum, item) => sum + (item.foodItem.price * item.quantity));
  }

  double get tax => subtotal * 0.18;
  double get serviceCharge => subtotal * 0.10;

  List<OrderItem> getOrdersByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  void updateOrderStatus(int orderIndex, OrderStatus newStatus) {
    if (orderIndex >= 0 && orderIndex < orders.length) {
      orders[orderIndex].status = newStatus;
      if (newStatus == OrderStatus.sent) {
        orders[orderIndex].isEditable = false;
        orders[orderIndex].cancelEditTimer();
      }
    }
  }

  void addSpecialRequest(String request) {
    specialRequests = request;
  }

  void assignWaiter(String name) {
    waiterName = name;
  }

  void addTip(double amount) {
    tip = amount;
  }

  Map<String, dynamic> toJson() {
    return {
      'tableNumber': tableNumber,
      'customer': customer != null ? {
        'name': customer!.name,
        'phone': customer!.phone,
        'guests': customer!.guests,
      } : null,
      'orders': orders.map((order) => {
        'foodItem': {
          'name': order.foodItem.name,
          'price': order.foodItem.price,
          'category': order.foodItem.category,
        },
        'quantity': order.quantity,
        'addedTime': order.addedTime.toIso8601String(),
        'status': order.status.toString(),
        'specialInstructions': order.specialInstructions,
      }).toList(),
      'isCompleted': isCompleted,
      'orderStartTime': orderStartTime?.toIso8601String(),
      'lastOrderTime': lastOrderTime?.toIso8601String(),
      'specialRequests': specialRequests,
      'tip': tip,
      'waiterName': waiterName,
    };
  }
}

// Temporary order item for cart
class TempOrderItem {
  final FoodItem foodItem;
  int quantity;

  TempOrderItem({required this.foodItem, this.quantity = 1});
}

// Global Data Store
class DataStore {
  static final DataStore _instance = DataStore._internal();
  factory DataStore() => _instance;
  DataStore._internal();

  final Map<int, TableOrder> _tables = {};
  final List<FoodItem> _foodItems = [
    FoodItem(name: 'Paneer Butter Masala', price: 180, category: 'Main Course'),
    FoodItem(name: 'Dal Makhani', price: 160, category: 'Main Course'),
    FoodItem(name: 'Chicken Biryani', price: 220, category: 'Rice'),
    FoodItem(name: 'Veg Biryani', price: 180, category: 'Rice'),
    FoodItem(name: 'Naan', price: 40, category: 'Bread'),
    FoodItem(name: 'Roti', price: 20, category: 'Bread'),
    FoodItem(name: 'Lassi', price: 60, category: 'Beverages'),
    FoodItem(name: 'Tea', price: 30, category: 'Beverages'),
    FoodItem(name: 'Coffee', price: 40, category: 'Beverages'),
    FoodItem(name: 'Gulab Jamun', price: 80, category: 'Desserts'),
  ];

  // Add more food categories
  final Map<String, List<String>> _customizations = {
    'Spice Level': ['Mild', 'Medium', 'Hot', 'Extra Hot'],
    'Cooking Preference': ['Rare', 'Medium Rare', 'Medium', 'Well Done'],
    'Additions': ['Extra Cheese', 'Extra Sauce', 'Extra Vegetables'],
    'Exclusions': ['No Onion', 'No Garlic', 'No Spicy'],
  };

  // Staff management
  final List<String> _staff = ['John', 'Alice', 'Bob', 'Emma'];
  Map<String, List<int>> _staffTables = {};

  List<FoodItem> get foodItems => _foodItems;
  List<String> get staff => _staff;
  Map<String, List<String>> get customizations => _customizations;

  // Table management
  TableOrder getTable(int tableNumber) {
    return _tables[tableNumber] ??= TableOrder(tableNumber: tableNumber);
  }

  bool isTableBooked(int tableNumber) {
    return _tables.containsKey(tableNumber) && _tables[tableNumber]!.customer != null;
  }

  void bookTable(int tableNumber, Customer customer) {
    final table = getTable(tableNumber);
    table.customer = customer;
    table.orderStartTime = DateTime.now();
    _saveTables(); // Save after modification
  }

  void releaseTable(int tableNumber) {
    if (_tables.containsKey(tableNumber)) {
      // Remove table from staff assignment
      for (var staff in _staffTables.keys) {
        _staffTables[staff]?.remove(tableNumber);
      }
      _tables.remove(tableNumber);
      _saveTables(); // Save after modification
    }
  }

  // Staff management
  void assignStaffToTable(String staffName, int tableNumber) {
    _staffTables[staffName] ??= [];
    _staffTables[staffName]!.add(tableNumber);
  }

  List<int> getStaffTables(String staffName) {
    return _staffTables[staffName] ?? [];
  }

  // Persistence
  Future<void> _saveTables() async {
    // TODO: Implement actual persistence
    // This is where you would save to local storage or a database
    final tablesJson = _tables.map((key, value) => MapEntry(key.toString(), value.toJson()));
    print('Saving tables: $tablesJson');
  }

  Future<void> loadTables() async {
    // TODO: Implement actual persistence
    // This is where you would load from local storage or a database
  }

  // Analytics
  Map<String, dynamic> getDailySalesReport() {
    double totalSales = 0;
    int totalOrders = 0;
    Map<String, int> itemsSold = {};
    
    for (var table in _tables.values) {
      if (table.isCompleted) {
        totalSales += table.totalAmount;
        totalOrders += table.orders.length;
        
        for (var order in table.orders) {
          itemsSold[order.foodItem.name] = 
            (itemsSold[order.foodItem.name] ?? 0) + order.quantity;
        }
      }
    }

    return {
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'itemsSold': itemsSold,
    };
  }
}

// Home Page - Table Selection
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataStore _dataStore = DataStore();
  final int totalTables = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Tables'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: totalTables,
          itemBuilder: (context, index) {
            final tableNumber = index + 1;
            final isBooked = _dataStore.isTableBooked(tableNumber);
            
            return GestureDetector(
              onTap: () => _handleTableTap(tableNumber, isBooked),
              child: Container(
                decoration: BoxDecoration(
                  color: isBooked ? Colors.red[100] : Colors.green[100],
                  border: Border.all(
                    color: isBooked ? Colors.red : Colors.green,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.table_restaurant,
                      size: 40,
                      color: isBooked ? Colors.red[700] : Colors.green[700],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Table $tableNumber',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isBooked ? Colors.red[700] : Colors.green[700],
                      ),
                    ),
                    Text(
                      isBooked ? 'Booked' : 'Available',
                      style: TextStyle(
                        fontSize: 12,
                        color: isBooked ? Colors.red[600] : Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleTableTap(int tableNumber, bool isBooked) {
    if (isBooked) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderPage(tableNumber: tableNumber),
        ),
      ).then((_) => setState(() {}));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerDetailsPage(tableNumber: tableNumber),
        ),
      ).then((_) => setState(() {}));
    }
  }
}

// Customer Details Page
class CustomerDetailsPage extends StatefulWidget {
  final int tableNumber;

  const CustomerDetailsPage({super.key, required this.tableNumber});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guestsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${widget.tableNumber} - Customer Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guestsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Guests',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of guests';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter valid number of guests';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitCustomerDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continue to Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitCustomerDetails() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        name: _nameController.text,
        phone: _phoneController.text,
        guests: int.parse(_guestsController.text),
      );

      DataStore().bookTable(widget.tableNumber, customer);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderPage(tableNumber: widget.tableNumber),
        ),
      );
    }
  }
}

// Order Page with Cart functionality
class OrderPage extends StatefulWidget {
  final int tableNumber;

  const OrderPage({super.key, required this.tableNumber});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final DataStore _dataStore = DataStore();
  late TableOrder _tableOrder;
  List<TempOrderItem> _cartItems = [];
  bool _isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _tableOrder = _dataStore.getTable(widget.tableNumber);
  }

  @override
  void dispose() {
    // Cancel all edit timers when disposing
    for (var order in _tableOrder.orders) {
      order.cancelEditTimer();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasOrders = _tableOrder.orders.isNotEmpty;
    final hasCartItems = _cartItems.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${widget.tableNumber} - Order'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: hasOrders ? [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsPage(tableNumber: widget.tableNumber),
                ),
              );
            },
          ),
        ] : null,
      ),
      body: Column(
        children: [
          if (_tableOrder.customer != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer: ${_tableOrder.customer!.name}'),
                  Text('Phone: ${_tableOrder.customer!.phone}'),
                  Text('Guests: ${_tableOrder.customer!.guests}'),
                ],
              ),
            ),
          // Show current table orders if any
          if (hasOrders) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Table Orders:', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    child: ListView.builder(
                      itemCount: _tableOrder.orders.length,
                      itemBuilder: (context, index) {
                        final order = _tableOrder.orders[index];
                        return Card(
                          child: ListTile(
                            title: Text(order.foodItem.name),
                            subtitle: Text('₹${order.foodItem.price} x ${order.quantity}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('₹${(order.foodItem.price * order.quantity).toStringAsFixed(2)}'),
                                if (order.isEditable) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                                    onPressed: () => _editOrderItem(index),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Food menu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Menu:', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _dataStore.foodItems.length,
                    itemBuilder: (context, index) {
                      final foodItem = _dataStore.foodItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(foodItem.name),
                          subtitle: Text('${foodItem.category} - ₹${foodItem.price}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.green),
                            onPressed: () => _addToCart(foodItem),
                          ),
                          onTap: () => _addToCart(foodItem),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasOrders ? _addToTable : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasOrders ? Colors.orange : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Send to Kitchen'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasOrders ? _completeOrder : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasOrders ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Complete Order'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: hasCartItems
          ? FloatingActionButton.extended(
              onPressed: _showCartBottomSheet,
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.shopping_cart),
              label: Text('${_cartItems.length} items'),
            )
          : null,
    );
  }

  void _addToCart(FoodItem foodItem) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.foodItem.name == foodItem.name,
      );

      if (existingIndex != -1) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(TempOrderItem(foodItem: foodItem));
      }
    });
  }

  void _editOrderItem(int orderIndex) {
    final orderItem = _tableOrder.orders[orderIndex];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${orderItem.foodItem.name}'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current quantity: ${orderItem.quantity}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: orderItem.quantity > 1 ? () {
                      setDialogState(() {
                        orderItem.quantity--;
                      });
                    } : null,
                  ),
                  Text('${orderItem.quantity}', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () {
                      setDialogState(() {
                        orderItem.quantity++;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _tableOrder.orders.removeAt(orderIndex);
              });
              Navigator.pop(context);
            },
            child: const Text('Remove Item', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showCartBottomSheet() {
    if (_isBottomSheetOpen) return;
    
    setState(() {
      _isBottomSheetOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = _cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(cartItem.foodItem.name),
                        subtitle: Text('₹${cartItem.foodItem.price} each'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setModalState(() {
                                  if (cartItem.quantity > 1) {
                                    cartItem.quantity--;
                                  } else {
                                    _cartItems.removeAt(index);
                                  }
                                });
                                setState(() {});
                              },
                            ),
                            Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () {
                                setModalState(() {
                                  cartItem.quantity++;
                                });
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${_calculateCartTotal().toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setModalState(() {
                                _cartItems.clear();
                              });
                              setState(() {});
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Clear Cart'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _addCartToTable();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Add to Table'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _isBottomSheetOpen = false;
      });
    });
  }

  double _calculateCartTotal() {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.foodItem.price * item.quantity));
  }

  void _addCartToTable() {
    setState(() {
      for (final cartItem in _cartItems) {
        final existingOrderIndex = _tableOrder.orders.indexWhere(
          (order) => order.foodItem.name == cartItem.foodItem.name,
        );

        if (existingOrderIndex != -1) {
          _tableOrder.orders[existingOrderIndex].quantity += cartItem.quantity;
          // Reset the edit timer for the existing item
          _tableOrder.orders[existingOrderIndex].isEditable = true;
          _tableOrder.orders[existingOrderIndex].startEditTimer(() {
            setState(() {});
          });
        } else {
          final orderItem = OrderItem(
            foodItem: cartItem.foodItem,
            quantity: cartItem.quantity,
            addedTime: DateTime.now(),
            isEditable: true,
          );
          
          // Start 1-minute timer for editing
          orderItem.startEditTimer(() {
            setState(() {});
          });
          
          _tableOrder.orders.add(orderItem);
        }
      }
      // Don't clear cart items here - keep them for potential reordering
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Items added to table successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addToTable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order sent to kitchen'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _completeOrder() {
    // Clear cart when completing order
    setState(() {
      _cartItems.clear();
    });
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillPage(tableNumber: widget.tableNumber),
      ),
    );
  }
}

// Statistics Page
class StatisticsPage extends StatelessWidget {
  final int tableNumber;

  const StatisticsPage({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context) {
    final tableOrder = DataStore().getTable(tableNumber);

    return Scaffold(
      appBar: AppBar(
        title: Text('Table $tableNumber - Statistics'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tableOrder.customer != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Customer Information', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Name: ${tableOrder.customer!.name}'),
                      Text('Phone: ${tableOrder.customer!.phone}'),
                      Text('Guests: ${tableOrder.customer!.guests}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Total Items: ${tableOrder.orders.length}'),
                    Text('Subtotal: ₹${tableOrder.subtotal.toStringAsFixed(2)}'),
                    Text('Tax (18%): ₹${tableOrder.tax.toStringAsFixed(2)}'),
                    Text('Service Charge (10%): ₹${tableOrder.serviceCharge.toStringAsFixed(2)}'),
                    const Divider(),
                    Text('Total Amount: ₹${tableOrder.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ordered Items', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: tableOrder.orders.length,
                itemBuilder: (context, index) {
                  final order = tableOrder.orders[index];
                  return Card(
                    child: ListTile(
                      title: Text(order.foodItem.name),
                      subtitle: Text('₹${order.foodItem.price} x ${order.quantity}'),
                      trailing: Text('₹${(order.foodItem.price * order.quantity).toStringAsFixed(2)}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bill Page
class BillPage extends StatelessWidget {
  final int tableNumber;

  const BillPage({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context) {
    final tableOrder = DataStore().getTable(tableNumber);

    return Scaffold(
      appBar: AppBar(
        title: Text('Table $tableNumber - Bill'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bill Details', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (tableOrder.customer != null) ...[
                      Text('Customer: ${tableOrder.customer!.name}'),
                      Text('Phone: ${tableOrder.customer!.phone}'),
                      Text('Guests: ${tableOrder.customer!.guests}'),
                      const Divider(),
                    ],
                    ...tableOrder.orders.map((order) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${order.foodItem.name} x ${order.quantity}'),
                        Text('₹${(order.foodItem.price * order.quantity).toStringAsFixed(2)}'),
                      ],
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('₹${tableOrder.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tax (18%):'),
                        Text('₹${tableOrder.tax.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Service Charge (10%):'),
                        Text('₹${tableOrder.serviceCharge.toStringAsFixed(2)}'),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('₹${tableOrder.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      DataStore().releaseTable(tableNumber);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Complete Payment'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back to Order'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}