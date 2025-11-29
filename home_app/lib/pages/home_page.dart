import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import '../helpers/dialog_helpers.dart';
import '../widgets/profile_header.dart';
import '../widgets/date_scroller.dart';
import '../helpers/utils.dart';
import 'progress_page.dart';
import 'settings_page.dart';
import 'goals_page.dart';
import 'habits_page.dart';
import '../app_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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

    return AnimatedBuilder(
      animation: state,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: state.backgroundColor,
          appBar: AppBar(
            title: const Text('Life Goals'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => showQuickAdd(context),
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProgressPage()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsPage()));
                },
              ),
            ],
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ProfileHeader(date: state.selectedDate),
                const SizedBox(height: 16),
                DateScroller(
                  selectedDate: state.selectedDate,
                  onSelect: (date) {
                    state.selectedDate = date;
                    state.notifyListeners();
                  },
                ),
                const SizedBox(height: 24),
                const Text('Goals',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...state.goals.map((g) {
                  return ListTile(
                    title: Text(g.title),
                    trailing: Checkbox(
                        value: g.done, onChanged: (_) => state.toggleGoal(g.id)),
                    onTap: () => state.toggleGoal(g.id),
                  );
                }),
                const SizedBox(height: 24),
                const Text('Habits',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...state.habits.asMap().entries.map((entry) {
                  final index = entry.key;
                  final h = entry.value;
                  final isDone =
                      h.completions.contains(AppState.dayKey(state.selectedDate));
                  return ListTile(
                    title: Text(h.title),
                    subtitle: Text('Streak: ${h.streak}'),
                    trailing: IconButton(
                      icon: Icon(
                          isDone ? Icons.check_box : Icons.check_box_outline_blank),
                      onPressed: () => state.toggleHabit(index, state.selectedDate),
                    ),
                    onTap: () => state.toggleHabit(index, state.selectedDate),
                  );
                }).toList(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue.shade200,
            child: const Icon(Icons.add),
            onPressed: () => showQuickAdd(context),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
              if (index == 0) {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const HomePage()));
              } else if (index == 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            HabitsPage(day: state.selectedDate)));
              } else if (index == 2) {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProgressPage()));
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.flag), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.repeat), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
            ],
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
          ),
        );
      },
    );
  }
}









