import 'package:flutter/material.dart';
import 'package:learning/left_right_set/left_right_game.dart';
import 'package:learning/memory/memory_game.dart';
import 'package:learning/puzzle/shuffle_puzzle.dart';
import 'package:learning/puzzle/shuffle_puzzle_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Image.asset(
              "assets/4Z_2101.w023.n001.9B.p161.9.jpg",
              fit: BoxFit.fitHeight,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MenuTile(
                text: "Mengen vergleichen",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LeftRightGame(),
                    ),
                  );
                },
              ),
              MenuTile(
                text: "Schiebe-Puzzle Zahlen",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShufflePuzzle(
                        width: 4,
                        shuffleType: ShuffleType.number,
                      ),
                    ),
                  );
                },
              ),
              MenuTile(
                text: "Schiebe-Puzzle Bilder",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShufflePuzzle(
                          width: 3, shuffleType: ShuffleType.image),
                    ),
                  );
                },
              ),
              MenuTile(
                text: "Memory",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemoryGameWidget(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final String text;
  final Function() onTap;
  const MenuTile({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(alignment: Alignment.center, children: [
        Image.asset("assets/menu_tile.png"),
        Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 32),
        ),
      ]),
    );
  }
}
