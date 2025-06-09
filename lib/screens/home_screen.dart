import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../widgets/menu_item_card.dart';
import '../models/menu_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> _categories = [
    'All',
    'Appetizers',
    'Main Course',
    'Desserts',
    'Beverages',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_categories[index]),
                    selected: _selectedIndex == index,
                    onSelected: (selected) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.secondaryColor,
                    labelStyle: TextStyle(
                      color:
                          _selectedIndex == index
                              ? Colors.white
                              : AppTheme.textColor,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: 10, // TODO: Replace with actual menu items
              itemBuilder: (context, index) {
                // TODO: Replace with actual menu items
                final menuItem = MenuItem(
                  id: '1',
                  name: 'Sample Item $index',
                  description: 'This is a sample menu item description',
                  price: 9.99,
                  category: 'Main Course',
                  imageUrl: 'https://via.placeholder.com/150',
                );
                return MenuItemCard(
                  menuItem: menuItem,
                  onTap: () {
                    // TODO: Implement item selection
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement new order
        },
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
        backgroundColor: AppTheme.secondaryColor,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppTheme.secondaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          // TODO: Implement navigation
        },
      ),
    );
  }
}
