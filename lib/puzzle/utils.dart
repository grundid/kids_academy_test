import 'dart:math';

import 'package:flutter/material.dart';

class PuzzleTile {
  final Widget widget;
  final bool isEmpty;
  final int correctPosX;
  final int correctPosY;

  PuzzleTile(this.widget, this.isEmpty, this.correctPosX, this.correctPosY);
}

typedef PuzzleBoard = List<List<PuzzleTile>>;

class PuzzleGame {
  final PuzzleBoard board;
  PuzzleGame(this.board);

  void moveTile(PuzzleTile tile) {
    Offset emptyTileOffset = findEmpty();
    Offset tileOffset = findTile(tile);

    PuzzleTile emptyTile =
        board[emptyTileOffset.dx.toInt()][emptyTileOffset.dy.toInt()];
    board[emptyTileOffset.dx.toInt()][emptyTileOffset.dy.toInt()] = tile;
    board[tileOffset.dx.toInt()][tileOffset.dy.toInt()] = emptyTile;
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
}

class TilePosition<T> {
  final T value;
  final int posX;
  final int posY;

  TilePosition(this.value, this.posX, this.posY);
}

class NumberPuzzleGameCreator {
  final int width;

  NumberPuzzleGameCreator(this.width);

  PuzzleGame createGame() {
    int elements = width * width;
    PuzzleBoard board = List.generate(width, (index) => <PuzzleTile>[]);
    Random random = Random(DateTime.now().microsecond);
    List<TilePosition<int>> numbers = List.generate(elements - 1, (index) {
      int value = index + 1;
      int posX = index ~/ width;
      int posY = index % width;
      return TilePosition(value, posX, posY);
    });

    for (int x = 0; x < width; x++) {
      List<PuzzleTile> line = board[x];
      for (int y = 0; y < width; y++) {
        if (numbers.isNotEmpty) {
          TilePosition<int> tilePosition =
              numbers.removeAt(random.nextInt(numbers.length));

          line.add(PuzzleTile(
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/woodtile.png"),
                  Text(
                    "${tilePosition.value}",
                    style: TextStyle(color: Colors.white, fontSize: 64),
                  )
                ],
              ),
              false,
              x,
              y));
        } else {
          line.add(PuzzleTile(Container(), true, width - 1, width - 1));
        }
      }
    }
    return PuzzleGame(board);
  }
}