import 'package:flutter/material.dart';

class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.body,
    this.actions,
  });
  final List<Widget>? actions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          body,
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      "assets/back_button.png",
                      width: 48,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (actions != null)
            Align(
              alignment: Alignment.topRight,
              child: Column(
                children: actions!,
              ),
            )
        ],
      ),
    );
  }
}
