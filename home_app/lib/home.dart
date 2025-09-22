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
      backgroundColor: Colors.lightBlue[100],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,

        title: const Text(
          "Life Goals",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: false, // keep Life Goals on the left

        actions: [
          IconButton(
            icon: const Icon(Icons.access_time, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80), // make space for profile
          child: Column(
            children: const [
              Icon(Icons.person, size: 40, color: Colors.black),
              SizedBox(height: 4),
              Text(
                "My Profile",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8), // extra spacing so it won’t get cut
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 16),

          const Text(
            "Date",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Column(children: [Text("Sat"), Text("20")]),
              Column(children: [Text("Sun"), Text("21")]),
              Column(children: [Text("Mon"), Text("22")]),
              Column(children: [Text("Tue"), Text("23")]),
            ],
          ),

          const Spacer(),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed: () {}, child: const Text("My Goals")),
            TextButton(onPressed: () {}, child: const Text("My Habits")),
            const SizedBox(width: 40), // spacing for FAB
            TextButton(onPressed: () {}, child: const Text("Progress")),
            IconButton(icon: const Icon(Icons.add_box), onPressed: () {}),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
