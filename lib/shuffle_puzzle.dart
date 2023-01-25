import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/puzzle/utils.dart';
import 'package:learning/set_cubit.dart';
import 'package:learning/shuffle_puzzle_cubit.dart';

class ShufflePuzzle extends StatelessWidget {
  final ShuffleType shuffleType;
  final int width;

  const ShufflePuzzle(
      {super.key, required this.shuffleType, required this.width});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => ShufflePuzzleCubit(width, shuffleType),
        child: BlocBuilder<ShufflePuzzleCubit, AppState>(
          builder: (context, state) {
            return state is ShufflePuzzleInitialized
                ? Stack(
                    children: [
                      Row(
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
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: InkWell(
                              onTap: () {
                                context
                                    .read<ShufflePuzzleCubit>()
                                    .toggleHelpMode();
                              },
                              child: Image.asset(
                                "assets/help_button.png",
                                width: 96,
                              ),
                            ),
                          )
                        ],
                      ),
                      Center(
                        child: SizedBox(
                          width: 600,
                          height: 620,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              for (int x = 0; x < width; x++)
                                for (int y = 0; y < width; y++)
                                  PositionedPuzzleTile(
                                      x: x,
                                      y: y,
                                      helpMode: state is ShufflePuzzleHelpState,
                                      board: state.board,
                                      animateTo:
                                          (state is ShufflePuzzleAnimation)
                                              ? state.offset
                                              : null,
                                      animatedTile:
                                          (state is ShufflePuzzleAnimation)
                                              ? state.tile
                                              : null)
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container();
          },
        ),
      ),
    );
  }
}

class PositionedPuzzleTile extends StatelessWidget {
  final int x;
  final int y;
  final List<List<PuzzleTile>> board;
  final PuzzleTile? animatedTile;
  final Offset? animateTo;
  final bool helpMode;

  PositionedPuzzleTile(
      {super.key,
      required this.x,
      required this.y,
      required this.board,
      required this.helpMode,
      this.animateTo,
      this.animatedTile});

  @override
  Widget build(BuildContext context) {
    double widthTile = 600 / board.length;
    PuzzleTile tile = board[x][y];

    int posX = helpMode ? tile.correctPosX : x;
    int posY = helpMode ? tile.correctPosY : y;

    print(
        "helpMode: $helpMode, X/Y: $x/$y, correct X/Y: ${tile.correctPosX}/${tile.correctPosY}");

    if (tile.isEmpty) {
      return Positioned(
          left: widthTile * posX,
          top: widthTile * posY,
          width: widthTile,
          height: widthTile,
          child: Container());
    } else {
      return AnimatedPositioned(
        duration: Duration(milliseconds: 300),
        left: tile == animatedTile && animateTo != null
            ? widthTile * animateTo!.dx
            : widthTile * posX,
        top: tile == animatedTile && animateTo != null
            ? widthTile * animateTo!.dy
            : widthTile * posY,
        width: widthTile,
        height: widthTile,
        onEnd: () {
          context.read<ShufflePuzzleCubit>().animationDone();
        },
        child: InkWell(
          onTap: () {
            if (helpMode) {
              context.read<ShufflePuzzleCubit>().toggleHelpMode();
            } else {
              context.read<ShufflePuzzleCubit>().moveTile(tile);
            }
          },
          child: tile.widget,
        ),
      );
    }
  }
}
