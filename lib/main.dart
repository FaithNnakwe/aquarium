import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'helper.dart';

void main() {
  runApp(AquariumApp());
}

class AquariumApp extends StatefulWidget {
  @override
  _AquariumAppState createState() => _AquariumAppState();
}

class _AquariumAppState extends State<AquariumApp> with SingleTickerProviderStateMixin {
  List<Fish> fishList = [];
  double selectedSpeed = 2.0;
  Color selectedColor = Colors.blueAccent;
  late Timer _timer;
  bool collisionEnabled = true; // Toggle for collision effect

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      setState(() {
        for (var fish in fishList) {
          fish.move();
        }
        _checkAllCollisions();
      });
    });
  }

  void _addFish() {
    if (fishList.length < 10) {
      setState(() {
        fishList.add(Fish(
          color: selectedColor,
          speed: selectedSpeed,
          position: Offset(Random().nextDouble() * 280, Random().nextDouble() * 280),
        ));
      });
    }
  }

  Future<void> _saveSettings() async {
    await DatabaseHelper.instance.saveSettings(fishList.length, selectedSpeed, selectedColor.toString());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Settings saved!")));
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseHelper.instance.loadSettings();
    if (settings != null) {
      setState(() {
        selectedSpeed = settings['speed'];
        selectedColor = Color(int.parse(settings['color'].split('(0x')[1].split(')')[0], radix: 16));
        fishList = List.generate(settings['fish_count'], (index) => Fish(
          color: selectedColor,
          speed: selectedSpeed,
          position: Offset(Random().nextDouble() * 280, Random().nextDouble() * 280),
        ));
      });
    }
  }

  Future<void> _clearData() async {
    await DatabaseHelper.instance.clearSettings();
    setState(() {
      fishList.clear();
      selectedSpeed = 2.0;
      selectedColor = Colors.orange;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data cleared!")));
  }

  void _checkAllCollisions() {
    if (!collisionEnabled) return;

    for (int i = 0; i < fishList.length; i++) {
      for (int j = i + 1; j < fishList.length; j++) {
        _checkForCollision(fishList[i], fishList[j]);
      }
    }
  }

  void _checkForCollision(Fish fish1, Fish fish2) {
    double dx = (fish1.position.dx - fish2.position.dx).abs();
    double dy = (fish1.position.dy - fish2.position.dy).abs();
    
    if (dx < 20 && dy < 20) { // Collision detected
      fish1.changeDirection();
      fish2.changeDirection();

      setState(() {
        fish1.color = Random().nextBool() ? Colors.blue : Colors.red;
        fish2.color = Random().nextBool() ? Colors.green : Colors.yellow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Virtual Aquarium")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  border: Border.all(color: Colors.black),
                ),
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
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _addFish, child: Text("Add Fish")),
              ElevatedButton(onPressed: _saveSettings, child: Text("Save Settings")),
              ElevatedButton(onPressed: _clearData, child: Text("Clear Data")),
              SwitchListTile(
                title: Text("Enable Collision Effect"),
                value: collisionEnabled,
                onChanged: (value) {
                  setState(() {
                    collisionEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Fish {
  Color color;
  double speed;
  Offset position;
  Offset direction;

  Fish({required this.color, required this.speed, required this.position})
      : direction = Offset(Random().nextDouble() * 2 - 1, Random().nextDouble() * 2 - 1);

  void move() {
    position = Offset(position.dx + direction.dx * speed, position.dy + direction.dy * speed);
    
    // Keep fish inside the aquarium (300x300 container)
    if (position.dx <= 0 || position.dx >= 280) {
      direction = Offset(-direction.dx, direction.dy);
    }
    if (position.dy <= 0 || position.dy >= 280) {
      direction = Offset(direction.dx, -direction.dy);
    }
  }

  void changeDirection() {
    direction = Offset(-direction.dx, -direction.dy);
  }
}
