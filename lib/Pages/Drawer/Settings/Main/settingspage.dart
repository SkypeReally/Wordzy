import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Drawer/Settings/Toggle/dropdown_tile.dart';
import 'package:gmae_wordle/Pages/Drawer/Settings/Instances/reset_button.dart';
import 'package:gmae_wordle/Pages/Drawer/Settings/Toggle/switchtile.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
// import 'package:gmae_wordle/Service/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final stats = context.read<StatsProvider>();

    final TextEditingController nameController = TextEditingController(
      text: settings.displayName,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          children: [
            // 🔹 Display Name TextField
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Display Name",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.edit),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                settings.setDisplayName(value);
                FocusScope.of(context).unfocus(); // Dismiss keyboard
              },
            ),

            const SizedBox(height: 20),

            SettingsSwitchTile(
              title: "Enable Sound",
              value: settings.isSoundEnabled,
              onChanged: settings.toggleSound,
            ),
            SettingsSwitchTile(
              title: "Enable Vibration",
              value: settings.isHapticEnabled,
              onChanged: settings.toggleHaptic,
            ),
            SettingsSwitchTile(
              title: "Use Physical Keyboard",
              value: settings.isPhysicalKeyboardEnabled,
              onChanged: settings.togglePhysicalKeyboard,
            ),
            SettingsSwitchTile(
              title: "Enable Tile Animation",
              value: settings.isTileAnimationEnabled,
              onChanged: settings.toggleTileAnimation,
            ),
            SettingsDropdownTile(
              title: "Default Word Length",
              value: settings.defaultWordLength,
              onChanged: settings.setDefaultWordLength,
            ),
            const Divider(height: 32),
            SettingsResetButton(
              label: "Reset All Stats",
              onPressed: () => _confirmResetAllStats(context, stats),
            ),
            const Divider(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmResetAllStats(
    BuildContext context,
    StatsProvider stats,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reset All Stats"),
        content: const Text("By clicking OK, every stat will reset."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close the dialog first
              await stats.resetStats(); // ✅ Await async call
              await stats.resetDailyStats(); // ✅ Await async call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All stats have been reset.")),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
