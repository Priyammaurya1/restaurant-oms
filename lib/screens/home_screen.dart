import 'package:flutter/material.dart';
import '../models/restaurant_models.dart' as models;
import 'order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<models.Table> tables = [];
  int selectedTableIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeTables();
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
        tip: 0,
      ),
    );

    // Set 2 random tables as occupied with sample data
    tables[4] = models.Table(
      number: 5,
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
          sentTime: DateTime.now().subtract(Duration(minutes: 5)),
        ),
        models.OrderItem(
          id: '2',
          itemId: '5',
          itemName: 'Biryani',
          price: 350,
          quantity: 2,
          sentTime: DateTime.now().subtract(Duration(minutes: 5)),
        ),
        models.OrderItem(
          id: '3',
          itemId: '7',
          itemName: 'Mango Lassi',
          price: 120,
          quantity: 3,
          sentTime: DateTime.now().subtract(Duration(minutes: 5)),
        ),
      ],
      orderSentTime: DateTime.now().subtract(Duration(minutes: 5)),
      tip: 0,
    );

    tables[11] = models.Table(
      number: 12,
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
          sentTime: DateTime.now().subtract(Duration(minutes: 10)),
        ),
        models.OrderItem(
          id: '5',
          itemId: '6',
          itemName: 'Dal Makhani',
          price: 220,
          quantity: 1,
          sentTime: DateTime.now().subtract(Duration(minutes: 10)),
        ),
        models.OrderItem(
          id: '6',
          itemId: '8',
          itemName: 'Masala Chai',
          price: 80,
          quantity: 2,
          sentTime: DateTime.now().subtract(Duration(minutes: 10)),
        ),
      ],
      orderSentTime: DateTime.now().subtract(Duration(minutes: 10)),
      tip: 0,
    );
  }

  // Add this method to properly reset combined tables
  void _resetCombinedTables(int mainTableIndex) {
    final mainTable = tables[mainTableIndex];

    // Check if this is a combined table
    if (mainTable.customerName.contains('Combined Tables')) {
      // Extract table numbers from the name
      try {
        final tableNumbers =
            mainTable.customerName
                .split(' - ')[0]
                .replaceAll('Combined Tables ', '')
                .split('-')
                .map((e) => int.parse(e.trim()))
                .toList();

        setState(() {
          // Reset all tables in the combination
          for (int tableNum in tableNumbers) {
            int tableIndex = tableNum - 1;
            if (tableIndex >= 0 && tableIndex < tables.length) {
              tables[tableIndex] = models.Table(
                number: tableNum,
                status: models.TableStatus.empty,
                customerName: '',
                phoneNumber: '',
                guestCount: 0,
                orders: [],
                orderSentTime: null,
                tip: 0,
              );
            }
          }
        });
      } catch (e) {
        // Fallback: reset just the main table if parsing fails
        setState(() {
          tables[mainTableIndex] = models.Table(
            number: mainTableIndex + 1,
            status: models.TableStatus.empty,
            customerName: '',
            phoneNumber: '',
            guestCount: 0,
            orders: [],
            orderSentTime: null,
            tip: 0,
          );
        });
      }
    } else {
      // Regular table reset
      setState(() {
        tables[mainTableIndex] = models.Table(
          number: mainTableIndex + 1,
          status: models.TableStatus.empty,
          customerName: '',
          phoneNumber: '',
          guestCount: 0,
          orders: [],
          orderSentTime: null,
          tip: 0,
        );
      });
    }
  }

  // Add this method to be called when any table needs to be reset
  void resetTable(int tableIndex) {
    _resetCombinedTables(tableIndex);
  }

  @override
  Widget build(BuildContext context) {
    int availableTables =
        tables.where((t) => t.status == models.TableStatus.empty).length;
    int occupiedTables =
        tables.where((t) => t.status == models.TableStatus.occupied).length;
    int totalTips = tables.fold(0, (sum, table) => sum + table.tip);

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Waiter Pro',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box, color: Color(0xFF1A1A1A)),
            onPressed: () => _showTableCombinationDialog(),
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    'Available',
                    '$availableTables',
                    Icons.event_seat,
                    Color(0xFF4CAF50),
                  ),
                  _buildStatCard(
                    'Occupied',
                    '$occupiedTables',
                    Icons.people,
                    Color(0xFFFF6B35),
                  ),
                  _buildStatCard(
                    'Total Tips',
                    '₹$totalTips',
                    Icons.monetization_on,
                    Color(0xFF2196F3),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tables Overview',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${tables.length} Total',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate the number of columns based on screen width
                    final crossAxisCount =
                        constraints.maxWidth > 800
                            ? 5
                            : constraints.maxWidth > 600
                            ? 4
                            : 3;
                    final spacing = 16.0;
                    final itemWidth =
                        (constraints.maxWidth -
                            (spacing * (crossAxisCount - 1))) /
                        crossAxisCount;
                    final itemHeight =
                        itemWidth *
                        0.95; // Increased from 0.8 to 0.9 for more height

                    return SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          alignment: WrapAlignment.start,
                          children: List.generate(tables.length, (index) {
                            final table = tables[index];
                            if (table.customerName.startsWith('Part of')) {
                              return SizedBox.shrink();
                            }

                            if (table.customerName.startsWith(
                              'Combined Tables',
                            )) {
                              final tableNumbers =
                                  table.customerName
                                      .split(' - ')[0]
                                      .replaceAll('Combined Tables ', '')
                                      .split('-')
                                      .map((e) => int.parse(e))
                                      .toList();

                              final span =
                                  tableNumbers.last - tableNumbers.first + 1;
                              final width =
                                  (itemWidth * span) + (spacing * (span - 1));
                              // Increase height based on number of combined tables
                              final combinedHeight =
                                  itemHeight * (span > 2 ? 1.2 : 1.0);

                              return SizedBox(
                                width: width,
                                height: combinedHeight,
                                child: _buildCombinedTableCard(
                                  table,
                                  tableNumbers,
                                ),
                              );
                            }

                            return SizedBox(
                              width: itemWidth,
                              height: itemHeight,
                              child: _buildTableCard(table, index),
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(models.Table table, int index) {
    Color cardColor = Colors.white;
    Color textColor = Color(0xFF1A1A1A);
    IconData statusIcon = Icons.event_seat;
    bool isPartOfCombined = table.customerName.startsWith('Part of');
    bool isMainCombined = table.customerName.startsWith('Combined Tables');

    switch (table.status) {
      case models.TableStatus.empty:
        cardColor = Colors.white;
        textColor = Color(0xFF666666);
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
      onTap: () => _handleTableTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border:
              selectedTableIndex == index
                  ? Border.all(color: Color(0xFFFF6B35), width: 2)
                  : Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: textColor, size: 20),
            ),
            SizedBox(height: 6),
            Text(
              isPartOfCombined ? '' : 'T${table.number}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 15,
              ),
            ),
            if (table.status == models.TableStatus.occupied &&
                !isPartOfCombined) ...[
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${table.guestCount} guests',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleTableTap(int index) {
    if (tables[index].status == models.TableStatus.empty) {
      _showCustomerDetailsDialog(index);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => OrderScreen(
                table: tables[index],
                onOrderUpdate: (updatedTable) {
                  setState(() {
                    tables[index] = updatedTable;
                  });
                },
                // Add callback for when order is completed
                onOrderComplete: () {
                  _resetCombinedTables(index);
                },
                // Add callback for table reset - this handles the actual reset
                onTableReset: (tableIndex) {
                  _resetCombinedTables(tableIndex);
                },
              ),
        ),
      );
    }
  }

  void _showCustomerDetailsDialog(int index) {
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
          title: Text('Customer Details - ${tables[index].customerName}'),
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
                      status: models.TableStatus.occupied,
                      customerName: nameController.text,
                      phoneNumber: phoneController.text,
                      guestCount: int.tryParse(guestController.text) ?? 0,
                    );
                  });
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(
                    // Navigate directly to OrderScreen
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => OrderScreen(
                            table: tables[index],
                            onOrderUpdate: (updatedTable) {
                              setState(() {
                                tables[index] = updatedTable;
                              });
                            },
                            onOrderComplete: () {
                              _resetCombinedTables(index);
                            },
                            onTableReset: (tableIndex) {
                              _resetCombinedTables(tableIndex);
                            },
                          ),
                    ),
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
      onTap: () => _handleTableTap(tableNumbers.first - 1),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Color(0xFFE8F5E8),
          borderRadius: BorderRadius.circular(20),
          border:
              selectedTableIndex == tableNumbers.first - 1
                  ? Border.all(color: Color(0xFFFF6B35), width: 2)
                  : Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF2E7D32).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people, color: Color(0xFF2E7D32), size: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Combined\nT${tableNumbers.join("-")}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                fontSize: 16,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${table.guestCount} guests',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                  _handleTableTap(tableNumbers.first - 1);
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
