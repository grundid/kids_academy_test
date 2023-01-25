import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

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

class ImagePuzzleGameCreator {
  final int width;
  final String imageFilename;

  ImagePuzzleGameCreator(
    this.width,
    this.imageFilename,
  );

  List<img.Image> splitImage(
      img.Image inputImage, int horizontalPieceCount, int verticalPieceCount) {
    img.Image image = inputImage;

    final pieceWidth = (image.width / horizontalPieceCount).round();
    final pieceHeight = (image.height / verticalPieceCount).round();
    final pieceList = List<img.Image>.empty(growable: true);

    for (var y = 0; y < image.height; y += pieceHeight) {
      for (var x = 0; x < image.width; x += pieceWidth) {
        pieceList.add(img.copyCrop(image,
            x: x, y: y, width: pieceWidth, height: pieceHeight));
      }
    }

    return pieceList;
  }

  Future<PuzzleGame> createGame() async {
    ByteData imageData = await rootBundle.load(imageFilename);
    img.Image? image = img.decodeImage(imageData.buffer.asUint8List());
    int imageWidth = 1024;
    int tileWidth = 1024 ~/ width;

    int elements = width * width;
    PuzzleBoard board = List.generate(width, (index) => <PuzzleTile>[]);
    Random random = Random(DateTime.now().microsecond);
    List<TilePosition<Uint8List>> numbers =
        List.generate(elements - 1, (index) {
      int posX = index ~/ width;
      int posY = index % width;

      img.Image value = img.copyCrop(image!,
          x: posX * tileWidth,
          y: posY * tileWidth,
          width: tileWidth,
          height: tileWidth);
      ;
      return TilePosition(img.encodePng(value), posX, posY);
    });

    for (int x = 0; x < width; x++) {
      List<PuzzleTile> line = board[x];
      for (int y = 0; y < width; y++) {
        if (numbers.isNotEmpty) {
          TilePosition<Uint8List> tilePosition =
              numbers.removeAt(random.nextInt(numbers.length));

          line.add(PuzzleTile(
              Stack(
                alignment: Alignment.center,
                children: [Image.memory(tilePosition.value)],
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
