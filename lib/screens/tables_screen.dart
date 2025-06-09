import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/cart_model.dart';
import 'customer_info_screen.dart';
import 'bill_screen.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({Key? key}) : super(key: key);

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  // TODO: Replace with actual data from backend
  final List<TableModel> _tables = List.generate(
    12,
    (index) => TableModel(
      id: index.toString(),
      tableNumber: (index + 1).toString(),
      status: index % 3 == 0 ? TableStatus.occupied : TableStatus.available,
    ),
  );

  // TODO: Replace with actual cart data from backend
  final Map<String, Cart> _tableOrders = {};

  Color _getTableColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
    }
  }

  void _handleTableTap(TableModel table) async {
    if (table.status == TableStatus.occupied) {
      // Show dialog for occupied table
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Table ${table.tableNumber}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer: ${table.customerName ?? "N/A"}'),
                  Text('Guests: ${table.numberOfGuests ?? 0}'),
                  Text(
                    'Time: ${table.occupiedAt?.toString().split('.')[0] ?? "N/A"}',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCompleteOrderDialog(table);
                  },
                  child: const Text('Complete Order'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
      );
    } else {
      // Navigate to customer info screen and wait for cart data
      final cart = await Navigator.push<Cart>(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerInfoScreen(table: table),
        ),
      );

      // If we got cart data back, store it
      if (cart != null && mounted) {
        setState(() {
          _tableOrders[table.id] = cart;
        });
      }
    }
  }

  void _showCompleteOrderDialog(TableModel table) {
    final cart = _tableOrders[table.id];
    if (cart != null && cart.items.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillScreen(table: table, cart: cart),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Complete Order'),
              content: const Text('Did the customer leave without ordering?'),
              actions: [
                TextButton(
                  onPressed: () {
                    // Mark table as available
                    setState(() {
                      final index = _tables.indexWhere((t) => t.id == table.id);
                      _tables[index].status = TableStatus.available;
                      _tables[index].customerName = null;
                      _tables[index].customerPhone = null;
                      _tables[index].numberOfGuests = null;
                      _tables[index].occupiedAt = null;
                      _tableOrders.remove(table.id);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Yes, Left Without Order'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Tables'),
        backgroundColor: Colors.orange,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _tables.length,
        itemBuilder: (context, index) {
          final table = _tables[index];
          return InkWell(
            onTap: () => _handleTableTap(table),
            child: Container(
              decoration: BoxDecoration(
                color: _getTableColor(table.status).withOpacity(0.1),
                border: Border.all(
                  color: _getTableColor(table.status),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.table_restaurant,
                    size: 40,
                    color: _getTableColor(table.status),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Table ${table.tableNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    table.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getTableColor(table.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_tableOrders.containsKey(table.id))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.restaurant,
                        size: 16,
                        color: _getTableColor(table.status),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
