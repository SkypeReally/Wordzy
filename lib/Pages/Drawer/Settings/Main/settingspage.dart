import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Drawer/Settings/Toggle/dropdown_tile.dart';
import 'package:gmae_wordle/Pages/Drawer/Settings/Instances/reset_button.dart';
import 'package:gmae_wordle/Pages/Drawer/Settings/Toggle/switchtile.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    nameController = TextEditingController(text: settings.displayName);
    nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final stats = context.read<StatsProvider>();
    final currentName = settings.displayName.trim();
    final typedName = nameController.text.trim();
    final hasChanged = typedName != currentName;

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
            // 🔹 Display Name Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Display Name",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            hintText: "Enter your display name",
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: hasChanged
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                          color: hasChanged
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? 0.15
                                      : 0.12,
                                )
                              : Theme.of(context).brightness == Brightness.dark
                              ? const Color.fromARGB(255, 42, 42, 42)
                              : const Color(0xFFF5F5F5),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: hasChanged
                                ? () {
                                    settings.setDisplayName(typedName);
                                    FocusScope.of(context).unfocus();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Name updated."),
                                      ),
                                    );
                                  }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              child: Text(
                                "Save",
                                style: TextStyle(
                                  color: hasChanged
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).brightness ==
                                            Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
              Navigator.of(ctx).pop();
              await stats.resetStats();
              await stats.resetDailyStats();
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
