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
        children: [
          body,
          Align(
            alignment: Alignment.topCenter,
            child: Row(
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
                      width: 96,
                    ),
                  ),
                ),
                if (actions != null)
                  Row(
                    children: actions!,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
