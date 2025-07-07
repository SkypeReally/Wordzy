import 'package:flutter/material.dart';

class SettingsLogoutTile extends StatelessWidget {
  final VoidCallback onLogoutConfirmed;

  const SettingsLogoutTile({super.key, required this.onLogoutConfirmed});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true) {
      onLogoutConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text("Log Out"),
      textColor: Colors.red,
      iconColor: Colors.red,
      onTap: () => _confirmLogout(context),
    );
  }
}
