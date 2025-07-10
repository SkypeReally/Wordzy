import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static const String supportEmail = 'wordzygame@gmail.com';

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: Uri.encodeFull(
        'subject=Wordzy Support&body=Describe your issue here...',
      ),
    );

    if (await canLaunchUrl(emailUri)) {
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) _showFallbackDialog(context);
    } else {
      _showFallbackDialog(context);
    }
  }

  void _showFallbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("No Email App Found"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "We couldn't find any email app to send support mail.\nYou can copy the email below and use it manually:",
            ),
            const SizedBox(height: 12),
            SelectableText(
              supportEmail,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text("Copy Email"),
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: supportEmail));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email address copied")),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Need Help?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Tap the button below to contact us via email. If it doesn't work, you'll get the option to copy our email manually.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _launchEmail(context),
                icon: const Icon(Icons.email_outlined),
                label: const Text("Contact Support"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
