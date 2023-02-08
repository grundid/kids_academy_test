import 'dart:async';

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

  MemoryCubit(this.xSize, this.ySize) : super(InProgressState()) {
    memoryField = MemoryField(xSize: xSize, ySize: ySize);
    emit(MemoryInitialized(memoryField, true));
  }

  List<ImageCard> countOpen() {
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

  @override
  Future<void> close() async {
    if (true == timer?.isActive) {
      timer!.cancel();
    }
    return super.close();
  }

  hideOpen() {
    for (List<ImageCard> cards in memoryField.field) {
      for (ImageCard card in cards) {
        if (card.open && !card.solved) {
          card.open = false;
        }
      }
    }
    emit(MemoryInitialized(memoryField, true));
  }

  void toggleField(int x, int y) {
    if (memoryField.field[y][x].open) {
      memoryField.field[y][x].open = false;
    } else {
      memoryField.field[y][x].open = true;
    }
    List<ImageCard> openFields = countOpen();
    bool solved = false;
    if (openFields.length >= 2) {
      if (openFields.first.fileName == openFields.last.fileName) {
        solved = true;
        openFields.first.solved = true;
        openFields.last.solved = true;
      } else {
        timer = Timer(Duration(seconds: 2), () {
          hideOpen();
        });
      }
    }
    //print("openFields: $openFields");
    emit(MemoryInitialized(memoryField, openFields.length < 2 || solved));
  }
}
