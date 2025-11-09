import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import 'goals_page.dart';
import 'habits_page.dart';
import 'progress_page.dart';
import 'settings_page.dart';
import 'reminders_page.dart';
import '../widgets/profile_header.dart';
import '../widgets/date_scroller.dart';
import '../widgets/quick_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/sparkline.dart';
import '../helpers/dialogs.dart';
import '../helpers/utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AnimatedBuilder(
        animation: state,
        builder: (_, __) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark mode'),
                value: state.darkMode,
                onChanged: state.setDark,
              ),
              ListTile(
                title: const Text('About'),
                subtitle: const Text('Life Goals • Flutter single-file demo with persistence'),
                trailing: const Icon(Icons.info_outline),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Life Goals',
                  applicationVersion: '1.1',
                  applicationIcon: const Icon(Icons.flag),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}