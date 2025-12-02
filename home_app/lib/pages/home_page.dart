import 'package:flutter/material.dart';
import '../app_state_scope.dart';
import '../helpers/dialog_helpers.dart';
import '../widgets/profile_header.dart';
import '../widgets/date_scroller.dart';
import 'progress_page.dart';
import 'settings_page.dart';
import '../app_state.dart';
import '../helpers/utils.dart';

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

  Widget _buildHomeBody(AppState state) {
    final todayKey = Utils.dayKey(DateTime.now());

    return FadeTransition(
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...state.goals.map((g) {
            return ListTile(
              title: Text(
                g.title,
                style: TextStyle(
                    decoration: g.done ? TextDecoration.lineThrough : null),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                      value: g.done,
                      onChanged: (_) => state.toggleGoal(g.id)),
                  IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => state.deleteGoal(g.id))
                ],
              ),
              onTap: () => state.toggleGoal(g.id),
            );
          }),
          const SizedBox(height: 24),
          const Text('Habits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...state.habits.asMap().entries.map((entry) {
            final index = entry.key;
            final h = entry.value;
            final isDone = h.completions.contains(todayKey);

            return ListTile(
              title: Text(
                h.title,
                style: TextStyle(
                    decoration:
                        isDone ? TextDecoration.lineThrough : null),
              ),
              subtitle: Text('Streak: ${h.streak}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                        isDone ? Icons.check_box : Icons.check_box_outline_blank),
                    onPressed: () =>
                        state.toggleHabit(index, state.selectedDate),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => state.deleteHabit(h.id),
                  ),
                ],
              ),
              onTap: () => state.toggleHabit(index, state.selectedDate),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context);

    final pages = [
      _buildHomeBody(state),
      const ProgressPage(),
      const SettingsPage(),
    ];

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
               onPressed: () => DialogHelpers.showQuickAdd(context),
              ),
            ],
          ),
          body: pages[_selectedIndex],
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue.shade200,
            child: const Icon(Icons.add),
            onPressed: () => DialogHelpers.showQuickAdd(context),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.flag), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.repeat), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
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












