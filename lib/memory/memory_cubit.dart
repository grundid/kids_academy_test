import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/memory/memory_game.dart';
import 'package:learning/utils/bloc_utils.dart';

class MemoryInitialized extends AppState {
  final MemoryField memoryField;
  final bool playActive;

  MemoryInitialized(this.memoryField, this.playActive);
}

class MemoryCubit extends Cubit<AppState> {
  final int xSize;
  final int ySize;
  late MemoryField memoryField;
  late Timer? timer;
  final AudioPlayer audioPlayer = AudioPlayer();

  bool showFailedGuess = false;

  MemoryCubit(this.xSize, this.ySize) : super(InProgressState()) {
    memoryField = MemoryField(xSize: xSize, ySize: ySize);
    emit(MemoryInitialized(memoryField, true));
  }

  reset() {
    memoryField = MemoryField(xSize: xSize, ySize: ySize);
    emit(MemoryInitialized(memoryField, true));
  }

  List<ImageCard> countOpenUnsolved() {
    List<ImageCard> result = [];
    for (List<ImageCard> cards in memoryField.field) {
      for (ImageCard card in cards) {
        if (card.open && !card.solved) {
          result.add(card);
        }
      }
    }
    return result;
  }

  int countSolved() {
    int solved = 0;
    for (List<ImageCard> cards in memoryField.field) {
      for (ImageCard card in cards) {
        if (card.solved) {
          solved++;
        }
      }
    }
    return solved;
  }

  @override
  Future<void> close() async {
    if (true == timer?.isActive) {
      timer!.cancel();
    }
    audioPlayer.dispose();
    return super.close();
  }

  hideOpen() {
    showFailedGuess = false;
    for (List<ImageCard> cards in memoryField.field) {
      for (ImageCard card in cards) {
        if (card.open && !card.solved) {
          card.open = false;
        }
      }
    }
    emit(MemoryInitialized(memoryField, true));
  }

  void toggleField(int x, int y) async {
    if (showFailedGuess) {
      timer?.cancel();
      hideOpen();
    }

    if (memoryField.field[y][x].open) {
      memoryField.field[y][x].open = false;
    } else {
      memoryField.field[y][x].open = true;
    }
    List<ImageCard> openFields = countOpenUnsolved();
    bool solved = false;
    if (openFields.length >= 2) {
      if (openFields.first.fileName == openFields.last.fileName) {
        solved = true;
        openFields.first.solved = true;
        openFields.last.solved = true;
        await audioPlayer.stop();
        audioPlayer.play(AssetSource(
          "zapsplat_multimedia_game_sound_fun_magic_game_positive_bonus_award_level_up_001_61001.mp3",
        ));
      } else {
        showFailedGuess = true;
        timer = Timer(Duration(seconds: 2), () {
          hideOpen();
        });
      }
    }
    if (countSolved() == xSize * ySize) {
      audioPlayer
          .play(AssetSource("human_crowd_25_people_cheer_shout_yay.mp3"));
    }

    emit(MemoryInitialized(memoryField, true));
  }
}
