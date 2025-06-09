import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Table> tables = [];
  int selectedTableIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeTables();
  }

  void _initializeTables() {
    tables = List.generate(
      20,
      (index) => Table(
        number: index + 1,
        status: TableStatus.empty,
        customerName: '',
        phoneNumber: '',
        guestCount: 0,
        orders: [],
        orderSentTime: null,
      ),
    );

    // Set 2 random tables as occupied with sample data
    tables[4] = tables[4].copyWith(
      status: TableStatus.occupied,
      customerName: 'Raj Kumar',
      phoneNumber: '9876543210',
      guestCount: 4,
      orders: [
        OrderItem(
          id: '1',
          itemId: '4',
          itemName: 'Butter Chicken',
          price: 380,
          quantity: 1,
        ),
        OrderItem(
          id: '2',
          itemId: '5',
          itemName: 'Biryani',
          price: 350,
          quantity: 2,
        ),
        OrderItem(
          id: '3',
          itemId: '7',
          itemName: 'Mango Lassi',
          price: 120,
          quantity: 3,
        ),
      ],
      orderSentTime: DateTime.now().subtract(Duration(minutes: 5)),
    );

    tables[11] = tables[11].copyWith(
      status: TableStatus.occupied,
      customerName: 'Priya Sharma',
      phoneNumber: '9123456789',
      guestCount: 2,
      orders: [
        OrderItem(
          id: '4',
          itemId: '1',
          itemName: 'Paneer Tikka',
          price: 280,
          quantity: 1,
        ),
        OrderItem(
          id: '5',
          itemId: '6',
          itemName: 'Dal Makhani',
          price: 220,
          quantity: 1,
        ),
        OrderItem(
          id: '6',
          itemId: '8',
          itemName: 'Masala Chai',
          price: 80,
          quantity: 2,
        ),
      ],
      orderSentTime: DateTime.now().subtract(Duration(minutes: 10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    int availableTables =
        tables.where((t) => t.status == TableStatus.empty).length;
    int occupiedTables =
        tables.where((t) => t.status == TableStatus.occupied).length;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Waiter Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFFF6B35),
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.account_circle), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFF6B35),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Available Tables',
                  '$availableTables',
                  Icons.event_seat,
                ),
                _buildStatCard(
                  'Occupied Tables',
                  '$occupiedTables',
                  Icons.people,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tables Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  return _buildTableCard(tables[index], index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTableCard(Table table, int index) {
    Color cardColor;
    Color textColor;
    IconData statusIcon;

    switch (table.status) {
      case TableStatus.empty:
        cardColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        statusIcon = Icons.event_seat;
        break;
      case TableStatus.occupied:
        cardColor = Color(0xFFE8F5E8);
        textColor = Color(0xFF2E7D32);
        statusIcon = Icons.people;
        break;
      case TableStatus.reserved:
        cardColor = Color(0xFFFFF3E0);
        textColor = Color(0xFFE65100);
        statusIcon = Icons.schedule;
        break;
    }

    return GestureDetector(
      onTap: () => _handleTableTap(table, index),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border:
              selectedTableIndex == index
                  ? Border.all(color: Color(0xFFFF6B35), width: 2)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon, color: textColor, size: 24),
            SizedBox(height: 4),
            Text(
              'T${table.number}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 14,
              ),
            ),
            if (table.status == TableStatus.occupied) ...[
              SizedBox(height: 2),
              Text(
                '${table.guestCount}',
                style: TextStyle(color: textColor, fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleTableTap(Table table, int index) {
    setState(() {
      selectedTableIndex = index;
    });

    if (table.status == TableStatus.empty) {
      _showCustomerDetailsDialog(table, index);
    } else {
      _showTableOptionsDialog(table, index);
    }
  }

  void _showCustomerDetailsDialog(Table table, int index) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController guestController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Customer Details - Table ${table.number}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: guestController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Guests',
                  prefixIcon: Icon(Icons.group),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    guestController.text.isNotEmpty) {
                  setState(() {
                    tables[index] = tables[index].copyWith(
                      status: TableStatus.occupied,
                      customerName: nameController.text,
                      phoneNumber: phoneController.text,
                      guestCount: int.parse(guestController.text),
                    );
                  });
                  Navigator.pop(context);
                  _navigateToOrderScreen(tables[index], index);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Start Order'),
            ),
          ],
        );
      },
    );
  }

  void _showTableOptionsDialog(Table table, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Table ${table.number} - ${table.customerName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phone: ${table.phoneNumber}'),
              Text('Guests: ${table.guestCount}'),
              Text('Orders: ${table.orders.length}'),
              SizedBox(height: 10),
              Text(
                'Ordered Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...table.orders.map(
                (order) => Text('• ${order.itemName} x${order.quantity}'),
              ),
              SizedBox(height: 10),
              Text(
                'Total: ₹${table.orders.fold(0, (sum, order) => sum + (order.price * order.quantity))}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToOrderScreen(table, index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Take Order'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToOrderScreen(Table table, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderScreen(
              table: table,
              onOrderUpdate: (updatedTable) {
                setState(() {
                  tables[index] = updatedTable;
                });
              },
            ),
      ),
    );
  }
}

class OrderScreen extends StatefulWidget {
  final Table table;
  final Function(Table) onOrderUpdate;

  const OrderScreen({
    super.key,
    required this.table,
    required this.onOrderUpdate,
  });

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Table currentTable;
  List<MenuItem> menuItems = [];
  List<MenuItem> filteredItems = [];
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
      MenuItem(
        id: '1',
        name: 'Paneer Tikka',
        price: 280,
        category: 'Starters',
        image: '🧀',
      ),
      MenuItem(
        id: '2',
        name: 'Chicken Wings',
        price: 320,
        category: 'Starters',
        image: '🍗',
      ),
      MenuItem(
        id: '3',
        name: 'Spring Rolls',
        price: 180,
        category: 'Starters',
        image: '🥬',
      ),

      // Main Course
      MenuItem(
        id: '4',
        name: 'Butter Chicken',
        price: 380,
        category: 'Main Course',
        image: '🍛',
      ),
      MenuItem(
        id: '5',
        name: 'Biryani',
        price: 350,
        category: 'Main Course',
        image: '🍚',
      ),
      MenuItem(
        id: '6',
        name: 'Dal Makhani',
        price: 220,
        category: 'Main Course',
        image: '🍲',
      ),

      // Beverages
      MenuItem(
        id: '7',
        name: 'Mango Lassi',
        price: 120,
        category: 'Beverages',
        image: '🥤',
      ),
      MenuItem(
        id: '8',
        name: 'Masala Chai',
        price: 80,
        category: 'Beverages',
        image: '☕',
      ),
      MenuItem(
        id: '9',
        name: 'Fresh Lime',
        price: 90,
        category: 'Beverages',
        image: '🍋',
      ),

      // Desserts
      MenuItem(
        id: '10',
        name: 'Gulab Jamun',
        price: 140,
        category: 'Desserts',
        image: '🍯',
      ),
      MenuItem(
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
                    '${currentTable.orders.length} items',
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

  Widget _buildMenuItemCard(MenuItem item) {
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

  void _addItem(MenuItem item) {
    setState(() {
      currentTable.orders.add(
        OrderItem(
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

  void _removeItem(MenuItem item) {
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
    return currentTable.orders.fold(0, (sum, order) => sum + order.price);
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
        Map<String, List<OrderItem>> groupedOrders = {};
        for (var order in currentTable.orders) {
          if (groupedOrders.containsKey(order.itemName)) {
            groupedOrders[order.itemName]!.add(order);
          } else {
            groupedOrders[order.itemName] = [order];
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
              Expanded(
                child: ListView.builder(
                  itemCount: groupedOrders.length,
                  itemBuilder: (context, index) {
                    String itemName = groupedOrders.keys.elementAt(index);
                    List<OrderItem> orders = groupedOrders[itemName]!;
                    return ListTile(
                      title: Text(itemName),
                      subtitle: Text('₹${orders.first.price} each'),
                      trailing: Text(
                        '${orders.length} x ₹${orders.first.price * orders.length}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
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
                      currentTable.orders.isNotEmpty ? _goToBilling : null,
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
            Map<String, List<OrderItem>> groupedOrders = {};
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
                    List<OrderItem> orders = groupedOrders[itemName]!;
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
                                  MenuItem menuItem = menuItems.firstWhere(
                                    (item) => item.name == itemName,
                                  );
                                  currentTable.orders.add(
                                    OrderItem(
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
      currentTable = currentTable.copyWith(orderSentTime: DateTime.now());
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

class BillingScreen extends StatefulWidget {
  final Table table;
  final Function(Table) onBillingComplete;

  const BillingScreen({
    super.key,
    required this.table,
    required this.onBillingComplete,
  });

  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  double taxRate = 0.18; // 18% GST
  double discountPercent = 0.0;

  @override
  Widget build(BuildContext context) {
    Map<String, List<OrderItem>> groupedOrders = {};
    for (var order in widget.table.orders) {
      if (groupedOrders.containsKey(order.itemName)) {
        groupedOrders[order.itemName]!.add(order);
      } else {
        groupedOrders[order.itemName] = [order];
      }
    }

    double subtotal = widget.table.orders.fold(
      0,
      (sum, order) => sum + order.price,
    );
    double discount = subtotal * (discountPercent / 100);
    double taxableAmount = subtotal - discount;
    double tax = taxableAmount * taxRate;
    double total = taxableAmount + tax;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Bill - Table ${widget.table.number}'),
        backgroundColor: Color(0xFFFF6B35),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFF6B35),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer: ${widget.table.customerName}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Phone: ${widget.table.phoneNumber}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Guests: ${widget.table.guestCount}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
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
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Item',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Qty',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Price',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Total',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...groupedOrders.entries.map((entry) {
                          String itemName = entry.key;
                          List<OrderItem> orders = entry.value;
                          int quantity = orders.length;
                          int price = orders.first.price;
                          int itemTotal = price * quantity;

                          return Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text(itemName)),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '$quantity',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '₹$price',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '₹$itemTotal',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal:'),
                            Text('₹${subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        if (discount > 0) ...[
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Discount ($discountPercent%):'),
                              Text(
                                '-₹${discount.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tax (${(taxRate * 100).toInt()}%):'),
                            Text('₹${tax.toStringAsFixed(2)}'),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showDiscountDialog,
                          icon: Icon(Icons.discount),
                          label: Text('Add Discount'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _printBill(total),
                          icon: Icon(Icons.print),
                          label: Text('Print Bill'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _completeBilling(total),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Complete Payment - ₹${total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _showDiscountDialog() {
    TextEditingController discountController = TextEditingController(
      text: discountPercent.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Add Discount'),
          content: TextField(
            controller: discountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Discount Percentage',
              suffixText: '%',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double discount = double.tryParse(discountController.text) ?? 0;
                if (discount >= 0 && discount <= 100) {
                  setState(() {
                    discountPercent = discount;
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _printBill(double total) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bill printed successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _completeBilling(double total) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Payment Confirmation'),
          content: Text('Confirm payment of ₹${total.toStringAsFixed(2)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                // Clear the table
                Table clearedTable = widget.table.copyWith(
                  status: TableStatus.empty,
                  customerName: '',
                  phoneNumber: '',
                  guestCount: 0,
                  orders: [],
                  orderSentTime: null,
                );

                widget.onBillingComplete(clearedTable);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment completed! Table cleared.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Confirm Payment'),
            ),
          ],
        );
      },
    );
  }
}

// Data Models
enum TableStatus { empty, occupied, reserved }

class Table {
  final int number;
  final TableStatus status;
  final String customerName;
  final String phoneNumber;
  final int guestCount;
  final List<OrderItem> orders;
  final DateTime? orderSentTime;

  Table({
    required this.number,
    required this.status,
    required this.customerName,
    required this.phoneNumber,
    required this.guestCount,
    required this.orders,
    this.orderSentTime,
  });

  Table copyWith({
    int? number,
    TableStatus? status,
    String? customerName,
    String? phoneNumber,
    int? guestCount,
    List<OrderItem>? orders,
    DateTime? orderSentTime,
  }) {
    return Table(
      number: number ?? this.number,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      guestCount: guestCount ?? this.guestCount,
      orders: orders ?? this.orders,
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
