import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Drawer/Hard%20Mode/hard_mode.dart';
import 'package:gmae_wordle/Pages/Drawer/Hints/hint_page.dart';

import 'package:gmae_wordle/Pages/Drawer/Streak/streak_page.dart';
import 'package:gmae_wordle/Pages/Drawer/Support/supprt_page.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Authentication/Core/firebase_auth.dart';
import 'package:gmae_wordle/Instances/page_transition.dart';
import 'package:gmae_wordle/Pages/Drawer/Settings/Main/settingspage.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Main/statspage.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:gmae_wordle/Provider/theme_provider.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final rawName = context.watch<SettingsProvider>().displayName;
    final name = rawName.trim().isEmpty ? "Player" : rawName;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: Stack(
              children: [
                // Theme Toggle
                Positioned(
                  top: 23,
                  right: 32,
                  child: IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      size: 26,
                    ),
                    tooltip: 'Toggle Theme',
                    onPressed: () {
                      themeProvider.toggleTheme();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_circle, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Hello $name!",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🧠 Secondary Features
          _buildDrawerItem(
            icon: Icons.tips_and_updates,
            label: 'Hints',
            onTap: () => _navigate(context, const HintsPage()),
          ),
          _buildDrawerItem(
            icon: Icons.bar_chart,
            label: 'Stats',
            onTap: () => _navigate(context, const StatsPage()),
          ),

          _buildDrawerItem(
            icon: Icons.security,
            label: 'Streak Freeze',
            onTap: () => _navigate(context, const StreakPage()),
          ),

          _buildDrawerItem(
            icon: Icons.vpn_key,
            label: 'Hard Mode',
            onTap: () => _navigate(context, const HardModePage()),
          ),

          const Divider(),

          // ⚙️ Settings and Support
          _buildDrawerItem(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () => _navigate(context, const SettingsPage()),
          ),
          _buildDrawerItem(
            icon: Icons.support_agent,
            label: 'Support',
            onTap: () => _navigate(context, const SupportPage()),
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            label: 'Log Out',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _handleLogout(context),
          ),

          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text("v1.5 • Wordle Team", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, createSlideRoute(page));
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().signOut(context);
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}
