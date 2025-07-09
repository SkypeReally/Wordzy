import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Category/category_page.dart';
import 'package:gmae_wordle/Pages/Mains/Daily%20Word/Main/dailyword_page.dart';

import 'package:gmae_wordle/Pages/Mains/Menu/menu_drawer.dart';
import 'package:gmae_wordle/Pages/Mains/Menu/menu_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(), // 🏠 Play Game + Word Length
    DailyWordPage(), // 📅 Daily Word
    CategoriesPage(), // 🧩 Categories List
  ];

  final List<String> _titles = const ['Play', 'Daily Word', 'Categories'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex]), centerTitle: true),
      drawer: const MenuDrawer(), // drawer stays consistent
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: 'Play'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Daily',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
      ),
    );
  }
}
