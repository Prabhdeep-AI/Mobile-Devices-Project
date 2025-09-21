import 'package:flutter/material.dart';

void main() {
  runApp(LifeGoalsApp());
}

class LifeGoalsApp extends StatelessWidget {
  const LifeGoalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Goals',
      home: LifeGoalsHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LifeGoalsHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Life Goals"),
        actions: [
          IconButton(icon: Icon(Icons.access_time), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16),

          Text(
            "Date",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [Text("Sat"), Text("20")]),
              Column(children: [Text("Sun"), Text("21")]),
              Column(children: [Text("Mon"), Text("22")]),
              Column(children: [Text("Tue"), Text("23")]),
            ],
          ),

          SizedBox(height: 40),

          Center(
            child: Text(
              "My Profile",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed: () {}, child: Text("My Goals")),
            TextButton(onPressed: () {}, child: Text("My Habits")),
            SizedBox(width: 40), // spacing for home button
            TextButton(onPressed: () {}, child: Text("Progress")),
            IconButton(
              icon: Icon(Icons.add_box), // create goal/habit
              onPressed: () {},
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
