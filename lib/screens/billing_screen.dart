import 'package:flutter/material.dart';
import '../models/restaurant_models.dart' as models;

class BillingScreen extends StatefulWidget {
  final models.Table table;
  final Function(models.Table) onBillingComplete;

  const BillingScreen({
    super.key,
    required this.table,
    required this.onBillingComplete,
  });

  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  double taxRate = 0.18; // 18% tax
  double discountPercentage = 0.0;

  @override
  Widget build(BuildContext context) {
    // Group current orders
    Map<String, List<models.OrderItem>> currentGroupedOrders = {};
    for (var order in widget.table.orders) {
      if (currentGroupedOrders.containsKey(order.itemName)) {
        currentGroupedOrders[order.itemName]!.add(order);
      } else {
        currentGroupedOrders[order.itemName] = [order];
      }
    }

    // Group sent orders
    Map<String, List<models.OrderItem>> sentGroupedOrders = {};
    for (var order in widget.table.sentOrders) {
      if (sentGroupedOrders.containsKey(order.itemName)) {
        sentGroupedOrders[order.itemName]!.add(order);
      } else {
        sentGroupedOrders[order.itemName] = [order];
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Bill - Table ${widget.table.number}'),
        backgroundColor: Color(0xFFFF6B35),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: 24),
            if (widget.table.sentOrders.isNotEmpty) ...[
              _buildOrderSection('Sent to Kitchen', sentGroupedOrders),
              SizedBox(height: 24),
            ],
            if (widget.table.orders.isNotEmpty) ...[
              _buildOrderSection('Current Order', currentGroupedOrders),
              SizedBox(height: 24),
            ],
            _buildBillSummary(),
            SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSection(
    String title,
    Map<String, List<models.OrderItem>> groupedOrders,
  ) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B35),
            ),
          ),
          SizedBox(height: 12),
          ...groupedOrders.entries.map((entry) {
            String itemName = entry.key;
            List<models.OrderItem> orders = entry.value;
            int quantity = orders.length;
            int totalPrice = orders.first.price * quantity;

            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${orders.first.price} x $quantity',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹$totalPrice',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBillSummary() {
    int subtotal = _calculateSubtotal();
    double discount = subtotal * (discountPercentage / 100);
    double tax = (subtotal - discount) * taxRate;
    double total = subtotal - discount + tax;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B35),
            ),
          ),
          SizedBox(height: 12),
          _buildBillRow('Subtotal', '₹$subtotal'),
          _buildBillRow(
            'Discount (${discountPercentage}%)',
            '-₹${discount.toStringAsFixed(2)}',
          ),
          _buildBillRow(
            'Tax (${(taxRate * 100).toStringAsFixed(0)}%)',
            '₹${tax.toStringAsFixed(2)}',
          ),
          Divider(height: 24),
          _buildBillRow('Total', '₹${total.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Color(0xFFFF6B35) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _showDiscountDialog,
          icon: Icon(Icons.discount),
          label: Text('Add Discount'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _printBill,
          icon: Icon(Icons.print),
          label: Text('Print Bill'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _completeBilling,
          icon: Icon(Icons.check_circle),
          label: Text('Complete Payment'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  int _calculateSubtotal() {
    return widget.table.orders.fold(0, (sum, order) => sum + order.price) +
        widget.table.sentOrders.fold(0, (sum, order) => sum + order.price);
  }

  void _showDiscountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Discount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Discount Percentage',
                  suffixText: '%',
                ),
                onChanged: (value) {
                  setState(() {
                    discountPercentage = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _printBill() {
    // TODO: Implement bill printing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bill printing functionality to be implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _completeBilling() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Payment'),
          content: Text(
            'Are you sure you want to complete the payment and clear the table?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearTable();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _clearTable() {
    models.Table clearedTable = widget.table.copyWith(
      status: models.TableStatus.empty,
      customerName: '',
      phoneNumber: '',
      guestCount: 0,
      orders: [],
      sentOrders: [],
      orderSentTime: null,
    );
    widget.onBillingComplete(clearedTable);
  }
}
