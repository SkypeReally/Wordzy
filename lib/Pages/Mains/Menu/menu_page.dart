import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Mains/Menu/menu_button.dart';
import 'package:gmae_wordle/Pages/Mains/Menu/menu_drawer.dart'; // Ensure this import is correct

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(), // ✅ Attach your custom drawer here
      appBar: AppBar(
        title: const Text("Wordzy"),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () =>
                Scaffold.of(context).openDrawer(), // ✅ Open the drawer
          ),
        ),
      ),
      body: const SafeArea(child: Center(child: MenuButtons())),
    );
  }
}
