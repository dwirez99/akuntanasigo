import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'kategori_screen.dart';
import 'transaksi_screen.dart';
import 'analisis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransaksiScreen(),
    const AnalisisScreen(),
    const KategoriScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analisis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Kategori',
          ),
        ],
      ),
    );
  }
}