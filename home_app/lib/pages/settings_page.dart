// settings_page.dart
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
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Custom RGB picker
  Future<Color?> _showCustomColorPicker(BuildContext ctx, Color initial) async {
    Color current = initial;
    int r = current.red;
    int g = current.green;
    int b = current.blue;

    return showDialog<Color>(
      context: ctx,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick custom color'),
          content: StatefulBuilder(
            builder: (context, setState) {
              Color preview = Color.fromARGB(255, r, g, b);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 60,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: preview,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  Row(
                    children: [
                      const Text('R'),
                      Expanded(
                        child: Slider(
                          value: r.toDouble(),
                          min: 0,
                          max: 255,
                          onChanged: (v) => setState(() => r = v.toInt()),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('G'),
                      Expanded(
                        child: Slider(
                          value: g.toDouble(),
                          min: 0,
                          max: 255,
                          onChanged: (v) => setState(() => g = v.toInt()),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('B'),
                      Expanded(
                        child: Slider(
                          value: b.toDouble(),
                          min: 0,
                          max: 255,
                          onChanged: (v) => setState(() => b = v.toInt()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'
                        .toUpperCase(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final picked = Color.fromARGB(255, r, g, b);
                Navigator.of(context).pop(picked);
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
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

                // Dark Mode only (no Auto Theme)
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: state.darkMode,
                  onChanged: (v) => state.setDarkMode(v),
                ),

                const Divider(),

                // Primary Color Theme
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Primary Color Theme',
                    style: theme.textTheme.titleSmall!
                        .copyWith(color: Colors.grey.shade600),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // PRESET COLOR OPTIONS
                      ...AppState.backgroundOptions.map((opt) {
                        final selected = state.backgroundKey == opt.key;
                        return ActionChip(
                          avatar: Icon(
                            selected ? Icons.check : opt.icon,
                            color: selected ? Colors.white : opt.color,
                          ),
                          label: Text(
                            opt.name,
                            style: TextStyle(
                              color: selected ? Colors.white : null,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          backgroundColor: selected ? opt.color : null,
                          onPressed: () => state.setBackground(opt.key),
                        );
                      }),

                      // CUSTOM COLOR PICKER (no setCustomColor, no autoTheme)
                      ActionChip(
                        avatar: const Icon(Icons.colorize),
                        label: const Text("Custom"),
                        onPressed: () async {
                          final picked = await _showCustomColorPicker(
                            context,
                            state.backgroundColor,
                          );
                          if (picked != null) {
                            // Just apply new color directly
                            await state.updateBackgroundColor(picked);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Reminders
                ListTile(
                  leading: const Icon(Icons.alarm),
                  title: const Text('Reminders'),
                  subtitle: Text(
                    'Manage daily reminders: ${state.reminders.length} set',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RemindersPage()),
                    );
                  },
                ),

                const Divider(),

                // About
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




