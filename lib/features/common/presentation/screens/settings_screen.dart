import 'package:flutter/material.dart';
import 'package:frontend/data/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsProvider _settingsProvider;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();

    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _urlController = TextEditingController(text: _settingsProvider.currentBaseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _saveNewUrl(BuildContext context) {
    final newUrl = _urlController.text.trim();
    if (newUrl.isNotEmpty) {
      _settingsProvider
          .updateBaseUrl(newUrl)
          .then((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Updated URL to: $newUrl'), behavior: SnackBarBehavior.floating));
            });
          })
          .catchError((error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating URL: $error'), behavior: SnackBarBehavior.floating),
              );
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = _settingsProvider.currentBaseUrl;
    if (_urlController.text != currentUrl) {
      _urlController.text = currentUrl;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16.0,
            children: [
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'Backend URL', border: OutlineInputBorder()),
                keyboardType: TextInputType.url,
              ),
              Text(
                'Note: Some changes may not take effect until the app is restarted and all the services are updated.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic),
              ),
              FilledButton(onPressed: () => _saveNewUrl(context), child: const Text('Update URL')),
            ],
          ),
        ),
      ),
    );
  }
}
