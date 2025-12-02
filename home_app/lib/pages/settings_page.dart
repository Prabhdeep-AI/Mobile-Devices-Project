import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import '../app_state.dart';
import '../helpers/dialog_helpers.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = AppStateScope.read(context);
    _nameController.text = appState.profileName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.watch(context);

    return Scaffold(
      backgroundColor: appState.backgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Profile Name",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Enter profile name",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              appState.setProfileName(value);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => DialogHelpers.pickColorDialog(context),
            child: const Text("Change Background Color"),
          ),
          const SizedBox(height: 32),
          const Text(
            "Danger Zone",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Reset Everything?"),
                  content: const Text(
                      "This will erase all goals, habits, streaks, completions, AND reset the theme & profile name back to default. This cannot be undone."),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          appState.resetAll();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text("Reset")),
                  ],
                ),
              );
            },
            child: const Text("Reset All Data"),
          ),
        ],
      ),
    );
  }
}










