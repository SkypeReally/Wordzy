import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Mains/Menu/menu_appbar.dart';
import 'package:gmae_wordle/Pages/Mains/Menu/menu_button.dart';
import 'package:gmae_wordle/Pages/Mains/Menu/menu_drawer.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MenuAppBar(),
      ),
      drawer: const MenuDrawer(),

      body: SafeArea(child: Center(child: MenuButtons())),
    );
  }
}
