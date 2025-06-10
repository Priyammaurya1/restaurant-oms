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
          IconButton(
            icon: Icon(Icons.add_box),
            onPressed: () => _showTableCombinationDialog(),
          ),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = 4;
                  final spacing = 12.0;
                  final itemWidth =
                      (constraints.maxWidth -
                          (spacing * (crossAxisCount - 1))) /
                      crossAxisCount;

                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: List.generate(tables.length, (index) {
                        final table = tables[index];

                        // Skip if this table is part of a combination
                        if (table.customerName.startsWith('Part of')) {
                          return SizedBox.shrink();
                        }

                        // Handle combined tables
                        if (table.customerName.startsWith('Combined Tables')) {
                          // Extract table numbers from the name
                          final tableNumbers =
                              table.customerName
                                  .split(' - ')[0]
                                  .replaceAll('Combined Tables ', '')
                                  .split('-')
                                  .map((e) => int.parse(e))
                                  .toList();

                          // Calculate the width of the combined table
                          final span =
                              tableNumbers.last - tableNumbers.first + 1;
                          final width =
                              (itemWidth * span) + (spacing * (span - 1));

                          return Container(
                            width: width,
                            height: itemWidth,
                            child: _buildCombinedTableCard(table, tableNumbers),
                          );
                        }

                        // Regular table
                        return SizedBox(
                          width: itemWidth,
                          height: itemWidth,
                          child: _buildTableCard(table, index),
                        );
                      }),
                    ),
                  );
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
    bool isPartOfCombined = table.customerName.startsWith('Part of');
    bool isMainCombined = table.customerName.startsWith('Combined Tables');

    switch (table.status) {
      case models.TableStatus.empty:
        cardColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        statusIcon = Icons.event_seat;
        break;
      case models.TableStatus.occupied:
        if (isPartOfCombined) {
          cardColor = Color(0xFFE8F5E8).withOpacity(0.5);
          textColor = Color(0xFF2E7D32).withOpacity(0.5);
          statusIcon = Icons.people;
        } else if (isMainCombined) {
          cardColor = Color(0xFFE8F5E8);
          textColor = Color(0xFF2E7D32);
          statusIcon = Icons.people;
        } else {
          cardColor = Color(0xFFE8F5E8);
          textColor = Color(0xFF2E7D32);
          statusIcon = Icons.people;
        }
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
              isPartOfCombined ? '' : 'T${table.number}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 14,
              ),
            ),
            if (table.status == models.TableStatus.occupied &&
                !isPartOfCombined) ...[
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
          title: Text('Customer Details - ${table.customerName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                controller: guestController,
                decoration: InputDecoration(
                  labelText: 'Number of Guests',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
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
                      customerName: nameController.text,
                      phoneNumber: phoneController.text,
                      guestCount: int.tryParse(guestController.text) ?? 0,
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

  void _showTableCombinationDialog() {
    List<int> selectedTables = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool isTableSelectionValid(int tableNumber) {
              if (selectedTables.isEmpty) return true;

              // Check if the table is adjacent to any selected table
              return selectedTables.any(
                (selected) =>
                    (tableNumber == selected + 1) ||
                    (tableNumber == selected - 1),
              );
            }

            void handleTableSelection(int tableNumber) {
              final isOccupied =
                  tables[tableNumber - 1].status == models.TableStatus.occupied;

              if (isOccupied) return;

              if (selectedTables.contains(tableNumber)) {
                setState(() {
                  selectedTables.remove(tableNumber);
                });
              } else {
                if (isTableSelectionValid(tableNumber)) {
                  setState(() {
                    selectedTables.add(tableNumber);
                    // Sort tables to maintain continuous order
                    selectedTables.sort();
                  });
                }
              }
            }

            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Combine Tables',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Select tables in continuous order (minimum 2 tables required)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(tables.length, (index) {
                      final tableNumber = index + 1;
                      final isSelected = selectedTables.contains(tableNumber);
                      final isOccupied =
                          tables[index].status == models.TableStatus.occupied;

                      return FilterChip(
                        label: Text('Table $tableNumber'),
                        selected: isSelected,
                        onSelected:
                            (selected) => handleTableSelection(tableNumber),
                        selectedColor: Color(0xFFFF6B35).withOpacity(0.2),
                        checkmarkColor: Color(0xFFFF6B35),
                        disabledColor: Colors.grey[300],
                        labelStyle: TextStyle(
                          color: isOccupied ? Colors.grey : Colors.black,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            selectedTables.length >= 2
                                ? () {
                                  Navigator.pop(
                                    context,
                                  ); // Close combination dialog
                                  _showCombinedTableOptionsDialog(
                                    selectedTables,
                                  );
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF6B35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Combine'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCombinedTableCard(models.Table table, List<int> tableNumbers) {
    return GestureDetector(
      onTap: () => _handleTableTap(table, tableNumbers.first - 1),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFE8F5E8),
          borderRadius: BorderRadius.circular(16),
          border:
              selectedTableIndex == tableNumbers.first - 1
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
            Icon(Icons.people, color: Color(0xFF2E7D32), size: 24),
            SizedBox(height: 4),
            Text(
              'Combined\nT${tableNumbers.join("-")}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 2),
            Text(
              '${table.guestCount} guests',
              style: TextStyle(color: Color(0xFF2E7D32), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  void _showCombinedTableOptionsDialog(List<int> tableNumbers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Combined Tables ${tableNumbers.join("-")}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Number of Tables: ${tableNumbers.length}'),
              Text('Total Capacity: ${tableNumbers.length * 2} guests'),
              SizedBox(height: 20),
              Text(
                'Would you like to proceed with taking the order?',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                Navigator.pop(context); // Close options dialog
                _showCustomerDetailsDialogForCombinedTables(tableNumbers);
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

  void _showCustomerDetailsDialogForCombinedTables(List<int> tableNumbers) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController guestController = TextEditingController(
      text: (tableNumbers.length * 2).toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Customer Details - Combined Tables ${tableNumbers.join("-")}',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                controller: guestController,
                decoration: InputDecoration(
                  labelText: 'Number of Guests',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                readOnly: false,
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
                    phoneController.text.isNotEmpty) {
                  _combineTables(
                    tableNumbers,
                    nameController.text,
                    phoneController.text,
                  );
                  Navigator.pop(context); // Close customer details dialog
                  // Navigate to order screen for the first table in the combination
                  _navigateToOrderScreen(
                    tables[tableNumbers.first - 1],
                    tableNumbers.first - 1,
                  );
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

  void _combineTables(
    List<int> tableNumbers,
    String customerName,
    String phoneNumber,
  ) {
    // Find the first table in the sequence
    final firstTableIndex = tableNumbers.first - 1;

    setState(() {
      // Update the first table to show combined status
      tables[firstTableIndex] = tables[firstTableIndex].copyWith(
        status: models.TableStatus.occupied,
        customerName:
            'Combined Tables ${tableNumbers.join("-")} - $customerName',
        phoneNumber: phoneNumber,
        guestCount: tableNumbers.length * 2, // Assuming 2 guests per table
      );

      // Mark other tables as occupied but with a special status
      for (int i = 1; i < tableNumbers.length; i++) {
        int tableIndex = tableNumbers[i] - 1;
        tables[tableIndex] = tables[tableIndex].copyWith(
          status: models.TableStatus.occupied,
          customerName: 'Part of ${tableNumbers.first}',
          phoneNumber: '',
          guestCount: 0,
        );
      }
    });
  }
}
