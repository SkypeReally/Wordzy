import 'package:flutter/material.dart';

class SettingsDropdownTile extends StatelessWidget {
  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  const SettingsDropdownTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(title, style: theme.textTheme.bodyLarge),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: theme.colorScheme.surface,
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
              items: List.generate(6, (index) {
                final len = index + 3;
                return DropdownMenuItem(
                  value: len,
                  child: Text("$len Letters"),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
