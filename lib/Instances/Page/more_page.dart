import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Drawer/Hints/hint_page.dart';
import 'package:gmae_wordle/Pages/Drawer/Streak/streak_page.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Archive/archive_page.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Archive/definition_page.dart';
import 'package:gmae_wordle/Pages/Drawer/Hard%20Mode/hard_mode.dart';
import 'package:gmae_wordle/Pages/Drawer/Settings/Main/settingspage.dart';
import 'package:gmae_wordle/Pages/Drawer/Support/supprt_page.dart';
import 'package:gmae_wordle/Instances/page_transition.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      children: [
        _buildOption(
          context,
          Icons.tips_and_updates,
          'Hints',
          const HintsPage(),
        ),
        _buildOption(
          context,
          Icons.security,
          'Streak Freeze',
          const StreakPage(),
        ),
        _buildOption(context, Icons.list_alt, 'Archive', const ArchivePage()),
        _buildOption(
          context,
          Icons.menu_book,
          'Word Definitions',
          const DefinitionPage(word: 'HELLO'),
        ),
        _buildOption(context, Icons.vpn_key, 'Hard Mode', const HardModePage()),
        const Divider(),
        _buildOption(context, Icons.settings, 'Settings', const SettingsPage()),
        _buildOption(
          context,
          Icons.support_agent,
          'Support',
          const SupportPage(),
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String label,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, createSlideRoute(page)),
    );
  }
}
