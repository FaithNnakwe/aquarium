import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(AquariumApp());

class AquariumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AquariumScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Fish {
  Color color;
  double speed;
  Offset position;
  double dx, dy;

  Fish({required this.color, required this.speed})
      : position = Offset(Random().nextDouble() * 280, Random().nextDouble() * 280),
        dx = Random().nextDouble() * 2 - 1,
        dy = Random().nextDouble() * 2 - 1;

  void move() {
    position = Offset(position.dx + dx * speed, position.dy + dy * speed);
    _checkBounds();
  }

  void _checkBounds() {
    if (position.dx <= 0 || position.dx >= 280) {
      dx = -dx;
    }
    if (position.dy <= 0 || position.dy >= 280) {
      dy = -dy;
    }
  }
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> with SingleTickerProviderStateMixin {
  List<Fish> fishList = [];
  Color selectedColor = Colors.blue;
  double selectedSpeed = 1.0;
  bool collisionEnabled = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat();
    _controller.addListener(() {
      setState(() {
    for (int i = 0; i < fishList.length; i++) {
      fishList[i].move();
      for (int j = i + 1; j < fishList.length; j++) {
        _checkForCollision(fishList[i], fishList[j]); // <-- Collision check happens here (Line 53)
      }
    }
  });
    });
    _loadPreferences();
  }

  void _addFish() {
    if (fishList.length < 10) {
      setState(() {
        fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
      });
      _savePreferences();
    }
  }

  void _checkForCollision(Fish fish1, Fish fish2) {
    if ((fish1.position.dx - fish2.position.dx).abs() < 20 &&
        (fish1.position.dy - fish2.position.dy).abs() < 20) {
      setState(() {
        fish1.color = Random().nextBool() ? Colors.blue : Colors.red;
        fish2.color = Random().nextBool() ? Colors.green : Colors.yellow;
        fish1.dx = -fish1.dx;
        fish1.dy = -fish1.dy;
        fish2.dx = -fish2.dx;
        fish2.dy = -fish2.dy;
      });
    }
  }

  void _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('fish_count', fishList.length);
    prefs.setDouble('fish_speed', selectedSpeed);
    prefs.setInt('fish_color', selectedColor.value);
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      int count = prefs.getInt('fish_count') ?? 0;
      selectedSpeed = prefs.getDouble('fish_speed') ?? 1.0;
      selectedColor = Color(prefs.getInt('fish_color') ?? Colors.blue.value);
      fishList = List.generate(count, (index) => Fish(color: selectedColor, speed: selectedSpeed));
    });
  }

  void _clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      fishList.clear();
      selectedSpeed = 1.0;
      selectedColor = Colors.blue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      appBar: AppBar(title: Text("Virtual Aquarium")),
      body: Center(
  child: Column(
    mainAxisSize: MainAxisSize.min, // Ensures the column takes minimal vertical space
    children: [
      Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(color: Colors.blue[200], border: Border.all(color: Colors.black)),
        child: Stack(
          children: fishList.map((fish) => Positioned(
            left: fish.position.dx,
            top: fish.position.dy,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(shape: BoxShape.circle, color: fish.color),
            ),
          )).toList(),
        ),
      ),
      const SizedBox(height: 20), // Adds spacing between the aquarium and buttons
      ElevatedButton(onPressed: _addFish, child: Text("Add Fish")),
      ElevatedButton(onPressed: _savePreferences, child: Text("Save Settings")),
      ElevatedButton(onPressed: _clearData, child: Text("Clear Data")),
    ],
  ),
),
    );
  }
}

// Add these dependencies to pubspec.yaml
// dependencies:
//   flutter:
//     sdk: flutter
//   sqflite: ^2.2.6
//   path_provider: ^2.0.11
//   shared_preferences: ^2.0.15