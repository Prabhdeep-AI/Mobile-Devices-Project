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

// =============================================================
// Home
// =============================================================
class LifeGoalsHome extends StatefulWidget {
  const LifeGoalsHome({super.key});

  @override
  State<LifeGoalsHome> createState() => _LifeGoalsHomeState();
}

class _LifeGoalsHomeState extends State<LifeGoalsHome> {
  DateTime selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm),
            tooltip: 'Reminders',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersPage())),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: _ProfileHeader(date: selectedDay),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _DateScroller(
            initial: selectedDay,
            onSelect: (d) => setState(() => selectedDay = d),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _QuickCard(
                    label: 'Goals',
                    icon: Icons.flag,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsPage())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickCard(
                    label: 'Habits',
                    icon: Icons.repeat,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HabitsPage(day: selectedDay))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedBuilder(
                animation: state,
                builder: (_, __) {
                  final completed = state.goals.where((g) => g.done).length;
                  final total = state.goals.length;
                  final todayDone = state.habits
                      .where((h) => h.completions.contains(AppState._dayKey(selectedDay)))
                      .length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatCard(
                        title: 'Today',
                        lines: [
                          '$completed / $total goals completed',
                          '$todayDone habits checked in',
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Last 7 days'),
                      const SizedBox(height: 6),
                      _Sparkline(habits: state.habits),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsPage())),
              child: const Text('My Goals'),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HabitsPage(day: selectedDay))),
              child: const Text('My Habits'),
            ),
            const SizedBox(width: 40),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressPage())),
              child: const Text('Progress'),
            ),
            IconButton(
              icon: const Icon(Icons.add_box),
              tooltip: 'Quick Add',
              onPressed: () => _showQuickAdd(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.home),
        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}