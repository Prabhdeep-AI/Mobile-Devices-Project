// lib/app_state_scope.dart
import 'package:flutter/material.dart';
import 'app_state.dart';

/// AppStateScope is an InheritedNotifier wrapper around AppState (which
/// extends ChangeNotifier). It exposes safe helper methods:
///  - AppStateScope.watch(context)  -> subscribes and rebuilds on changes
///  - AppStateScope.read(context)   -> reads without subscribing (safe in initState)
///  - AppStateScope.maybeRead(context) -> returns nullable AppState if not present
///
/// Also includes a small BuildContext extension for convenience:
///   context.appStateWatch  (same as AppStateScope.watch(context))
///   context.appStateRead   (same as AppStateScope.read(context))
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    Key? key,
    required AppState notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);

  /// Subscribe and rebuild when AppState notifies.
  static AppState watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    if (scope == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('AppStateScope not found.'),
        ErrorHint('Wrap your app with AppStateScope(notifier: yourAppState, child: ...)')
      ]);
    }
    // notifier is non-null because we required it in constructor
    return scope.notifier!;
  }

  /// Read without subscribing (safe in initState / didChangeDependencies).
  static AppState read(BuildContext context) {
    final s = maybeRead(context);
    if (s == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('AppStateScope not found when calling read(context).'),
        ErrorHint('Wrap your app with AppStateScope(notifier: yourAppState, child: ...)')
      ]);
    }
    return s;
  }

  /// Same as `read` but returns nullable instead of throwing.
  static AppState? maybeRead(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppStateScope>();
    if (element == null) return null;
    final widget = element.widget as AppStateScope;
    return widget.notifier;
  }

  @override
  bool updateShouldNotify(covariant AppStateScope oldWidget) =>
      notifier != oldWidget.notifier;
}

/// Convenience extension on BuildContext.
extension AppStateContextX on BuildContext {
  /// Subscribe and rebuild on change.
  AppState get appStateWatch => AppStateScope.watch(this);

  /// Read without subscribing.
  AppState get appStateRead => AppStateScope.read(this);

  /// Nullable read.
  AppState? get appStateMaybeRead => AppStateScope.maybeRead(this);
}

