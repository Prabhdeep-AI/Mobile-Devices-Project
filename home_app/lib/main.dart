import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'app_state.dart';
import 'app_state_scope.dart';
import 'pages/home_page.dart';
import 'notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService.init();
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
    _init = appState.loadFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

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










