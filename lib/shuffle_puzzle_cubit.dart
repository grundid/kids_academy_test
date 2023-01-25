import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/puzzle/utils.dart';
import 'package:learning/set_cubit.dart';

class ShufflePuzzleInitialized extends AppState {
  final PuzzleBoard board;

  ShufflePuzzleInitialized(this.board);
}

class ShufflePuzzleAnimation extends ShufflePuzzleInitialized {
  final PuzzleTile tile;
  final Offset offset;

  ShufflePuzzleAnimation(super.board, this.tile, this.offset);
}

class ShufflePuzzleCubit extends Cubit<AppState> {
  late PuzzleGame puzzleGame;
  final AudioPlayer audioPlayer = AudioPlayer();

  ShufflePuzzleCubit(int width) : super(InProgressState()) {
    _init(width);
  }

  _init(int width) async {
    ImagePuzzleGameCreator creator =
        ImagePuzzleGameCreator(width, "assets/puppy-2785074_1920.jpg");
    puzzleGame = await creator.createGame();

    emit(ShufflePuzzleInitialized(puzzleGame.board));
  }

  moveTile(PuzzleTile tile) {
    if (state is ShufflePuzzleInitialized) {
      Offset emptyTileOffset = puzzleGame.findEmpty();
      Offset currentTileOffset = puzzleGame.findTile(tile);
      final diffX = (emptyTileOffset.dx - currentTileOffset.dx).abs().toInt();
      final diffY = (emptyTileOffset.dy - currentTileOffset.dy).abs().toInt();
      if ((diffX == 1 && diffY == 0) ^ (diffY == 1 && diffX == 0)) {
        audioPlayer.play(AssetSource(
            "zapsplat_foley_wood_blocks_small_slide_together_001_14091_short.mp3"));

        emit(ShufflePuzzleAnimation(puzzleGame.board, tile, emptyTileOffset));
      } else {
        audioPlayer.play(AssetSource('death.mp3'));
      }
    }
  }

  void animationDone() {
    if (state is ShufflePuzzleAnimation) {
      ShufflePuzzleAnimation myState = state as ShufflePuzzleAnimation;
      puzzleGame.moveTile(myState.tile);
      emit(ShufflePuzzleInitialized(puzzleGame.board));
    }
  }
}
