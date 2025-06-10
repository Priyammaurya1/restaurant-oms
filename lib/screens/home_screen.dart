import 'package:flutter/material.dart';
import '../models/restaurant_models.dart' as models;
import 'order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<models.Table> tables = [];
  int selectedTableIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeTables();
  }

  void _initializeTables() {
    tables = List.generate(
      20,
      (index) => models.Table(
        number: index + 1,
        status: models.TableStatus.empty,
        customerName: '',
        phoneNumber: '',
        guestCount: 0,
        orders: [],
        orderSentTime: null,
      ),
    );

    // Set 2 random tables as occupied with sample data
    tables[4] = tables[4].copyWith(
      status: models.TableStatus.occupied,
      customerName: 'Raj Kumar',
      phoneNumber: '9876543210',
      guestCount: 4,
      orders: [
        models.OrderItem(
          id: '1',
          itemId: '4',
          itemName: 'Butter Chicken',
          price: 380,
          quantity: 1,
        ),
        models.OrderItem(
          id: '2',
          itemId: '5',
          itemName: 'Biryani',
          price: 350,
          quantity: 2,
        ),
        models.OrderItem(
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
      status: models.TableStatus.occupied,
      customerName: 'Priya Sharma',
      phoneNumber: '9123456789',
      guestCount: 2,
      orders: [
        models.OrderItem(
          id: '4',
          itemId: '1',
          itemName: 'Paneer Tikka',
          price: 280,
          quantity: 1,
        ),
        models.OrderItem(
          id: '5',
          itemId: '6',
          itemName: 'Dal Makhani',
          price: 220,
          quantity: 1,
        ),
        models.OrderItem(
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
        tables.where((t) => t.status == models.TableStatus.empty).length;
    int occupiedTables =
        tables.where((t) => t.status == models.TableStatus.occupied).length;

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

  Widget _buildTableCard(models.Table table, int index) {
    Color cardColor = Colors.grey[100]!;
    Color textColor = Colors.grey[600]!;
    IconData statusIcon = Icons.event_seat;

    switch (table.status) {
      case models.TableStatus.empty:
        cardColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        statusIcon = Icons.event_seat;
        break;
      case models.TableStatus.occupied:
        cardColor = Color(0xFFE8F5E8);
        textColor = Color(0xFF2E7D32);
        statusIcon = Icons.people;
        break;
      case models.TableStatus.reserved:
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
            if (table.status == models.TableStatus.occupied) ...[
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

  void _handleTableTap(models.Table table, int index) {
    setState(() {
      selectedTableIndex = index;
    });

    if (table.status == models.TableStatus.empty) {
      _showCustomerDetailsDialog(table, index);
    } else {
      _showTableOptionsDialog(table, index);
    }
  }

  void _showCustomerDetailsDialog(models.Table table, int index) {
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
                      status: models.TableStatus.occupied,
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

  void _showTableOptionsDialog(models.Table table, int index) {
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

  void _navigateToOrderScreen(models.Table table, int index) {
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
