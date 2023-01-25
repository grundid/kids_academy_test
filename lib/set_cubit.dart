import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';

@immutable
class AppState {}

class InProgressState extends AppState {}

const SetElement noElement = SetElement(Colors.transparent);

class SetElement {
  final Color color;

  const SetElement(this.color);
}

class SetInitialized extends AppState {
  final List<SetElement> leftElements;
  final List<SetElement> rightElements;
  final Color challenge;
  final String status;
  SetInitialized(
      this.leftElements, this.rightElements, this.challenge, this.status);
}

class SetResponseInitialized extends SetInitialized {
  final bool correct;
  final int leftCount;
  final int rightCount;

  SetResponseInitialized(this.correct, this.leftCount, this.rightCount,
      super.leftElements, super.rightElements, super.challenge, super.status);
}

const double threshold = 0.8;

List<Color> possibleColors = [Colors.red, Colors.blue, Colors.green];

enum SetResponse { left, equal, right }

class SetCubit extends Cubit<AppState> {
  final int elements;
  final int colors;
  late List<SetElement> leftElements;
  late List<SetElement> rightElements;
  final Random randomGenerator = Random(DateTime.now().microsecond);
  final AudioPlayer audioPlayer = AudioPlayer();
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int correctInARow = 0;
  int level = 0;

  SetCubit(this.elements, this.colors) : super(InProgressState()) {
    _init();
  }

  SetElement _elementCreator(int index) {
    double random = randomGenerator.nextDouble();

    if (random < (threshold - (level * 0.08))) {
      return noElement;
    } else {
      int colorIndex =
          randomGenerator.nextInt(min(colors, possibleColors.length));
      return SetElement(possibleColors[colorIndex]);
    }
  }

  _init() {
    leftElements = List.generate(elements, _elementCreator);
    rightElements = List.generate(elements, _elementCreator);

    int colorIndex =
        randomGenerator.nextInt(min(colors, possibleColors.length));
    Color challenge = Colors.red;
    // possibleColors[colorIndex];

    emit(SetInitialized(leftElements, rightElements, challenge, _status()));
  }

  String _status() {
    return "Level: $level, Lauf: $correctInARow, $correctAnswers Richtige, $wrongAnswers Falsche";
  }

  update() {
    _init();
  }

  processResponse(SetResponse setResponse, Color challenge) async {
    int leftCount = leftElements.fold(
        0,
        (previousValue, element) =>
            element.color == challenge ? previousValue + 1 : previousValue);
    int rightCount = rightElements.fold(
        0,
        (previousValue, element) =>
            element.color == challenge ? previousValue + 1 : previousValue);

    bool correct =
        ((setResponse == SetResponse.left && leftCount > rightCount) ||
            (setResponse == SetResponse.equal && leftCount == rightCount) ||
            (setResponse == SetResponse.right && rightCount > leftCount));
    bool levelUp = false;
    if (correct) {
      correctAnswers++;
      correctInARow++;
      if (correctInARow >= 10) {
        level++;
        correctInARow = 0;
        levelUp = true;
      }
    } else {
      wrongAnswers++;
      correctInARow = 0;
    }

    emit(SetResponseInitialized(correct, leftCount, rightCount, leftElements,
        rightElements, challenge, _status()));
    if (correct) {
      if (levelUp) {
        if (level == 10) {
          audioPlayer.play(AssetSource("cartoon_success_fanfair.mp3"));
        } else {
          audioPlayer.play(AssetSource(
              "zapsplat_multimedia_game_sound_fun_magic_game_positive_bonus_award_level_up_001_61001.mp3"));
        }
      } else {
        audioPlayer.play(AssetSource(
            "zapsplat_multimedia_game_sound_advance_award_nylon_plucked_synth_001_40806.mp3"));
      }
    } else {
      audioPlayer.play(
          AssetSource("multimedia_game_sound_synth_tone_bold_fail_52993.mp3"));
    }
    await Future.delayed(Duration(seconds: correct ? 2 : 5));
    audioPlayer.stop();
    update();
  }
}
