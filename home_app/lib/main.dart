import 'package:flutter/material.dart';
import 'app_state.dart';
import 'app_state_scope.dart';
import 'pages/home_page.dart';
// import 'notifications.dart';  // Keep commented until implemented

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If notifications are added later:
  // await NotificationService.init();

  runApp(const LifeGoalsApp());
}

class LifeGoalsApp extends StatefulWidget {
  const LifeGoalsApp({super.key});

  @override
  State<LifeGoalsApp> createState() => _LifeGoalsAppState();
}

class _LifeGoalsAppState extends State<LifeGoalsApp> {
  final appState = AppState();
  late Future<void> _init;

  @override
  void initState() {
    super.initState();
    // Load all persisted data (goals, habits, reminders, background color)
    _init = appState.loadFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        // Show a loading indicator while initializing
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Once loaded, wrap MaterialApp with AppStateScope
        return AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            final scheme = ColorScheme.fromSeed(
              seedColor: appState.backgroundColor,
              brightness: appState.darkMode
                  ? Brightness.dark
                  : Brightness.light,
            );

            return AppStateScope(
              notifier: appState,
              child: MaterialApp(
                title: 'Life Goals',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  colorScheme: scheme,
                  useMaterial3: true,
                  scaffoldBackgroundColor: scheme.surface,
                ),
                home: const HomePage(),
              ),
            );
          },
        );
      },
    );
  }
}








