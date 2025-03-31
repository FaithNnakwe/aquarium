import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helper.dart';

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

// Example usage in your widget
class AquariumPage extends StatefulWidget {
  @override
  _AquariumPageState createState() => _AquariumPageState();
}

class _AquariumPageState extends State<AquariumPage> {
  int fishCount = 0;
  double fishSpeed = 1.0;
  Color fishColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load settings from SQLite
  _loadSettings() async {
    final settings = await DatabaseHelper().loadSettings();
    if (settings != null) {
      setState(() {
        fishCount = settings['fish_count'];
        fishSpeed = settings['speed'];
        fishColor = Color(int.parse(settings['color']));
      });
    }
  }

  // Save settings to SQLite
  _saveSettings() async {
    await DatabaseHelper().saveSettings(fishCount, fishSpeed, fishColor.value.toString());
  }

  // Clear settings
  _clearSettings() async {
    await DatabaseHelper().clearSettings();
    setState(() {
      fishCount = 0;
      fishSpeed = 1.0;
      fishColor = Colors.blue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Virtual Aquarium')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.blue[200], // Aquarium background
                border: Border.all(color: Colors.black),
              ),
              child: Stack(
                children: fishList.map((fish) => Positioned(
                  left: fish.position.dx,
                  top: fish.position.dy,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: fish.color,
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addFish,
              child: Text("Add Fish"),
            ),
            ElevatedButton(
              onPressed: _saveSettings,
              child: Text("Save Settings"),
            ),
            ElevatedButton(
              onPressed: _clearSettings,
              child: Text("Clear Data"),
            ),
          ],
        ),
      ),
    );
  }
}
