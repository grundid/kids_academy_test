import 'package:flutter/material.dart';
import 'package:learning/left_right_game.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: Text('Links-Rechts üben'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeftRightGame(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Schiebe-Puzzle'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Container(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
