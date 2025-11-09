import 'package:flutter/material.dart';
import 'app_state.dart';
import 'app_state_scope.dart';
import 'pages/home_page.dart';

void main() => runApp(const LifeGoalsApp());

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
    _init = appState.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: appState,
          builder: (context, __) {
            final scheme = ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: appState.darkMode ? Brightness.dark : Brightness.light,
            );
            return AppStateScope(
              notifier: appState,
              child: MaterialApp(
                title: 'Life Goals',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(colorScheme: scheme, useMaterial3: true),
                home: const LifeGoalsHome(),
              ),
            );
          },
        );
      },
    );
  }
}