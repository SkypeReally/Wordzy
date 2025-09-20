import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Mains/Menu/menu_button.dart';
import 'package:gmae_wordle/Pages/Mains/Menu/menu_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(),
      appBar: AppBar(
        title: const Text("Wordzy"),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: const SafeArea(child: Center(child: MenuButtons())),
    );
  }
}
