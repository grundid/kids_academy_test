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
    return GameScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final smallerSide = (constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight) *
              0.75;
          final tileSize = smallerSide / width;
          return BlocProvider(
            create: (context) => ShufflePuzzleCubit(width, shuffleType),
            child: BlocBuilder<ShufflePuzzleCubit, AppState>(
              builder: (context, state) {
                return state is ShufflePuzzleInitialized
                    ? Stack(
                        children: [
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
                                        x: x,
                                        y: y,
                                        i: tileSize,
                                        board: state.board,
                                        animateTo:
                                            (state is ShufflePuzzleAnimation)
                                                ? state.offset
                                                : null,
                                        animatedTile:
                                            (state is ShufflePuzzleAnimation)
                                                ? state.tile
                                                : null,
                                      )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container();
              },
            ),
          );
        },
      ),
    );
  }
}

class PositionedPuzzleTile extends StatelessWidget {
  final int x;
  final int y;
  final List<List<PuzzleTile>> board;
  final double i;
  final PuzzleTile? animatedTile;
  final Offset? animateTo;

  PositionedPuzzleTile({
    super.key,
    required this.x,
    required this.y,
    required this.board,
    required this.i,
    this.animateTo,
    this.animatedTile,
  });

  @override
  Widget build(BuildContext context) {
    PuzzleTile tile = board[x][y];
    if (tile.isEmpty) {
      return Positioned(
          left: i * x, top: i * y, width: i, height: i, child: Container());
    } else {
      return AnimatedPositioned(
        duration: Duration(milliseconds: 300),
        left: tile == animatedTile && animateTo != null
            ? i * animateTo!.dx
            : i * x,
        top: tile == animatedTile && animateTo != null
            ? i * animateTo!.dy
            : i * y,
        width: i,
        height: i,
        onEnd: () {
          context.read<ShufflePuzzleCubit>().animationDone();
        },
        child: InkWell(
          onTap: () {
            context.read<ShufflePuzzleCubit>().moveTile(tile);
          },
          child: tile.widget,
        ),
      );
    }
  }
}
