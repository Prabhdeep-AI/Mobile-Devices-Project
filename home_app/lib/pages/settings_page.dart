import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import '../app_state.dart';
import 'reminders_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: state,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: state.backgroundColor,
          appBar: AppBar(title: const Text('Settings')),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              children: [
                const SizedBox(height: 8),

                // --- Dark Mode ---
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: state.darkMode,
                  onChanged: state.setDarkMode,
                ),

                const Divider(),

                // --- Background Color ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Primary Color Theme',
                    style: theme.textTheme.titleSmall!
                        .copyWith(color: Colors.grey.shade600),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: AppState.backgroundOptions.map((opt) {
                    final selected = state.backgroundKey == opt.key;
                    return ActionChip(
                      avatar: Icon(
                        selected ? Icons.check : opt.icon,
                        color: selected
                            ? theme.colorScheme.onPrimary
                            : opt.color,
                      ),
                      label: Text(
                        opt.name,
                        style: TextStyle(
                          color: selected
                              ? theme.colorScheme.onPrimary
                              : opt.color,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      backgroundColor: selected ? opt.color : null,
                      onPressed: () => state.setBackground(opt.key),
                    );
                  }).toList(),
                ),

                const Divider(),

                // --- Reminders ---
                ListTile(
                  leading: const Icon(Icons.alarm),
                  title: const Text('Reminders'),
                  subtitle:
                      Text('Manage daily reminders: ${state.reminders.length} set'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RemindersPage()),
                    );
                  },
                ),

                const Divider(),

                // --- About ---
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  subtitle:
                      const Text('Life Goals • Flutter demo with persistence'),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Life Goals',
                    applicationVersion: '1.1',
                    applicationIcon: const Icon(Icons.flag),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Go Home',
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(Icons.home),
          ),
        );
      },
    );
  }
}


