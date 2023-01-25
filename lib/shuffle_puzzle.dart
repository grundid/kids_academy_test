import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/game_scaffold.dart';
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
    return BlocProvider(
      create: (context) => ShufflePuzzleCubit(width, shuffleType),
      child: GameScaffold(
        actions: [
          Builder(builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: InkWell(
                onTap: () {
                  context.read<ShufflePuzzleCubit>().toggleHelpMode();
                },
                child: Image.asset(
                  "assets/help_button.png",
                  width: 96,
                ),
              ),
            );
          })
        ],
        body: LayoutBuilder(
          builder: (context, constraints) {
            final smallerSide = (constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight) *
                0.75;
            final tileSize = smallerSide / width;
            return BlocBuilder<ShufflePuzzleCubit, AppState>(
              builder: (context, state) {
                return state is ShufflePuzzleInitialized
                    ? Stack(children: [
                        Center(
                          child: SizedBox(
                            width: smallerSide,
                            height: smallerSide,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                for (int x = 0; x < width; x++)
                                  for (int y = 0; y < width; y++)
                                    PositionedPuzzleTile(
                                        tileSize: tileSize,
                                        x: x,
                                        y: y,
                                        helpMode:
                                            state is ShufflePuzzleHelpState,
                                        board: state.board,
                                        animateTo:
                                            (state is ShufflePuzzleAnimation)
                                                ? state.offset
                                                : null,
                                        animatedTile:
                                            (state is ShufflePuzzleAnimation)
                                                ? state.tile
                                                : null),
                              ],
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
                        ),
                      ])
                    : Container();
              },
            );
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
  final double tileSize;
  final PuzzleTile? animatedTile;
  final Offset? animateTo;
  final bool helpMode;

  PositionedPuzzleTile({
    super.key,
    required this.x,
    required this.y,
    required this.board,
    required this.helpMode,
    required this.tileSize,
    this.animateTo,
    this.animatedTile,
  });

  @override
  Widget build(BuildContext context) {
    PuzzleTile tile = board[x][y];

    int posX = helpMode ? tile.correctPosX : x;
    int posY = helpMode ? tile.correctPosY : y;

    print(
        "helpMode: $helpMode, X/Y: $x/$y, correct X/Y: ${tile.correctPosX}/${tile.correctPosY}");

    if (tile.isEmpty) {
      return Positioned(
        left: tileSize * posX,
        top: tileSize * posY,
        width: tileSize,
        height: tileSize,
        child: Container(),
      );
    } else {
      return AnimatedPositioned(
        duration: Duration(milliseconds: 300),
        left: tile == animatedTile && animateTo != null
            ? tileSize * animateTo!.dx
            : tileSize * posX,
        top: tile == animatedTile && animateTo != null
            ? tileSize * animateTo!.dy
            : tileSize * posY,
        width: tileSize,
        height: tileSize,
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
