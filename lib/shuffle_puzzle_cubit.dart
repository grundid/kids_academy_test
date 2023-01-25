import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/set_cubit.dart';

class PuzzleTile {
  final String content;
  final bool isEmpty;

  PuzzleTile(this.content, this.isEmpty);
}

class ShufflePuzzleInitialized extends AppState {
  final List<List<PuzzleTile>> board;

  ShufflePuzzleInitialized(this.board);
}

class ShufflePuzzleAnimation extends ShufflePuzzleInitialized {
  final PuzzleTile tile;
  final Offset offset;

  ShufflePuzzleAnimation(super.board, this.tile, this.offset);
}

class ShufflePuzzleCubit extends Cubit<AppState> {
  late List<List<PuzzleTile>> board;
  final AudioPlayer audioPlayer = AudioPlayer();

  ShufflePuzzleCubit(int width) : super(InProgressState()) {
    int elements = width * width;
    board = List.generate(width, (index) => <PuzzleTile>[]);
    Random random = Random(DateTime.now().microsecond);
    List<int> numbers = List.generate(elements - 1, (index) => index + 1);
    for (int x = 0; x < width; x++) {
      List<PuzzleTile> line = board[x];
      for (int y = 0; y < width; y++) {
        if (numbers.isNotEmpty) {
          int tileNumber = numbers.removeAt(random.nextInt(numbers.length));

          line.add(PuzzleTile("$tileNumber", false));
        } else {
          line.add(PuzzleTile("", true));
        }
      }
    }
    emit(ShufflePuzzleInitialized(board));
  }

  Offset findEmpty() {
    for (int x = 0; x < board.length; x++) {
      List<PuzzleTile> line = board[x];
      for (int y = 0; y < line.length; y++) {
        PuzzleTile tile = line[y];
        if (tile.isEmpty) {
          return Offset(x.toDouble(), y.toDouble());
        }
      }
    }
    throw Exception("cannot happen");
  }

  Offset findTile(PuzzleTile tileToFind) {
    for (int x = 0; x < board.length; x++) {
      List<PuzzleTile> line = board[x];
      for (int y = 0; y < line.length; y++) {
        PuzzleTile tile = line[y];
        if (tile == tileToFind) {
          return Offset(x.toDouble(), y.toDouble());
        }
      }
    }
    throw Exception("cannot happen");
  }

  moveTile(PuzzleTile tile) {
    if (state is ShufflePuzzleInitialized) {
      Offset emptyTile = findEmpty();
      audioPlayer.play(AssetSource(
          "zapsplat_foley_wood_blocks_small_slide_together_001_14091_short.mp3"));

      emit(ShufflePuzzleAnimation(board, tile, emptyTile));
    }
  }

  void animationDone() {
    if (state is ShufflePuzzleAnimation) {
      ShufflePuzzleAnimation myState = state as ShufflePuzzleAnimation;
      Offset emptyTileOffset = myState.offset;
      Offset tileOffset = findTile(myState.tile);
      PuzzleTile emptyTile =
          board[emptyTileOffset.dx.toInt()][emptyTileOffset.dy.toInt()];
      board[emptyTileOffset.dx.toInt()][emptyTileOffset.dy.toInt()] =
          myState.tile;
      board[tileOffset.dx.toInt()][tileOffset.dy.toInt()] = emptyTile;
      emit(ShufflePuzzleInitialized(board));
    }
  }
}
