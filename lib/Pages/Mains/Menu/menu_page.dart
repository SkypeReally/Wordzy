import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Mains/Menu/menu_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBodyBehindAppBar: false,

      body: SafeArea(child: Center(child: MenuButtons())),
    );
  }
}
