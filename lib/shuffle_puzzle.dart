import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/puzzle/utils.dart';
import 'package:learning/set_cubit.dart';
import 'package:learning/shuffle_puzzle_cubit.dart';

class ShufflePuzzle extends StatelessWidget {
  const ShufflePuzzle({super.key});

  @override
  Widget build(BuildContext context) {
    int width = 4;
    return Scaffold(
      body: BlocProvider(
        create: (context) => ShufflePuzzleCubit(4),
        child: BlocBuilder<ShufflePuzzleCubit, AppState>(
          builder: (context, state) {
            return state is ShufflePuzzleInitialized
                ? Center(
                    child: SizedBox(
                        width: 600,
                        height: 620,
                        child: Stack(alignment: Alignment.center, children: [
                          for (int x = 0; x < width; x++)
                            for (int y = 0; y < width; y++)
                              PositionedPuzzleTile(
                                  x: x,
                                  y: y,
                                  board: state.board,
                                  animateTo: (state is ShufflePuzzleAnimation)
                                      ? state.offset
                                      : null,
                                  animatedTile:
                                      (state is ShufflePuzzleAnimation)
                                          ? state.tile
                                          : null)
                        ])),
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
  static double widthTile = 150;
  final PuzzleTile? animatedTile;
  final Offset? animateTo;

  PositionedPuzzleTile(
      {super.key,
      required this.x,
      required this.y,
      required this.board,
      this.animateTo,
      this.animatedTile});

  @override
  Widget build(BuildContext context) {
    PuzzleTile tile = board[x][y];
    if (tile.isEmpty) {
      return Positioned(
          left: widthTile * x,
          top: widthTile * y,
          width: widthTile,
          height: widthTile,
          child: Container());
    } else {
      return AnimatedPositioned(
        duration: Duration(milliseconds: 300),
        left: tile == animatedTile && animateTo != null
            ? widthTile * animateTo!.dx
            : widthTile * x,
        top: tile == animatedTile && animateTo != null
            ? widthTile * animateTo!.dy
            : widthTile * y,
        width: widthTile,
        height: widthTile,
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
