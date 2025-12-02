# Life Goals – Mobile Devices Project

Welcome to our app called Life Goals! This app helps you track goals, habits, and also you can set daily reminders! Here's everything we feature:

## Features
- Create and manage **goals** (with optional due dates)
- Track **habits** with daily completions and streaks
- Add **reminders** that trigger local notifications
- View a **progress** screen with summaries/visuals
- Simple **profile** section (name + customizable background color)
- Data stored locally using **SQLite** and **shared_preferences**
- Local notifications via `flutter_local_notifications` + `timezone`

## Tech Stack
- **Flutter**
- **Dart**
- **sqflite** for local database
- **shared_preferences** for small key–value storage
- **flutter_local_notifications** + `timezone` for scheduled notifications
- Custom widgets for stats, progress tiles, date scroller, etc.

## Project Structure
Main app folder:

```text
home_app/
  lib/
    main.dart           # App entry point (LifeGoalsApp)
    app_state.dart      # Global app state & business logic
    app_state_scope.dart
    db_helper.dart      # SQLite helpers
    models.dart         # Goal & Habit models
    notifications.dart  # Local notification setup
    pages/              # Home, Goals, Habits, Progress, Reminders, Settings
    widgets/            # Reusable UI components (cards, charts, etc.)
