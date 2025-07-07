import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsSupportTile extends StatelessWidget {
  const SettingsSupportTile({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'wordzygame@email.com',
      query: 'subject=Support%20Request%20for%20Wordzy%20Game',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open email app")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: const Icon(Icons.support_agent),
          title: const Text("Contact Support"),
          subtitle: const Text("wordzygame@email.com"),
          onTap: () => _launchEmail(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
