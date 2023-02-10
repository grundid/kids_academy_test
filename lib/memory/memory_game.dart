import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/game_scaffold.dart';
import 'package:learning/memory/memory_cubit.dart';
import 'package:learning/utils/bloc_utils.dart';

class Card {
  final Widget widget;
  final String content;
  final Offset position;

  Card(this.widget, this.content, this.position);
}

class CardPair {
  final Card firstCard;
  final Card secondCard;

  CardPair(this.firstCard, this.secondCard);
}

List<String> imageFiles = [
  "hund_frame.jpg",
  "tiger_frame.jpg",
  "loewe_frame.jpg",
  "eichhoernchen_frame.jpg",
  "elefant_frame.jpg",
  "katze_frame.jpg",
  "hunde_frame.jpg",
  "fisch_frame.jpg",
  "pferd_frame.jpg",
  "pinguine_frame.jpg",
  "zebras_frame.jpg",
  "waschbaer_frame.jpg",
  "hase_frame.jpg",
  "frosch_frame.jpg",
  "delphine_frame.jpg",
];

class ImageCard {
  final String fileName;
  bool open = false;
  bool solved = false;

  ImageCard(this.fileName);
}

class MemoryField {
  late List<List<ImageCard>> field;

  MemoryField({required int xSize, required int ySize}) {
    List<String> possibleImages = [];

    Random random = Random();
    List availableImages = List.from(imageFiles);
    for (int x = 0; x < (xSize * ySize) / 2; x++) {
      String fileName = availableImages.length > 1
          ? availableImages.removeAt(random.nextInt(availableImages.length))
          : availableImages.removeLast();
      possibleImages.add(fileName);
      possibleImages.add(fileName);
    }
    field = [];
    for (int y = 0; y < ySize; y++) {
      List<ImageCard> row = [];
      field.add(row);
      for (int x = 0; x < xSize; x++) {
        String fileName = possibleImages.length > 1
            ? possibleImages.removeAt(random.nextInt(possibleImages.length))
            : possibleImages.removeLast();
        ImageCard imageCard = ImageCard(fileName);
        row.add(imageCard);
      }
    }
  }
}

class MemoryCardWidget extends StatelessWidget {
  final String fileName;
  final bool open;
  final Function()? onTap;

  const MemoryCardWidget(
      {super.key,
      required this.open,
      required this.fileName,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Image.asset("assets/$fileName"),
          Image.asset(
              open ? "assets/memory_tile_empty.png" : "assets/memory_tile.png")
        ],
      ),
    );
  }
}

class MemoryGameWidget extends StatelessWidget {
  final int xSize = 6;
  final int ySize = 5;
  const MemoryGameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double width = xSize * 128;
    double height = ySize * 192 / 2;

    return BlocProvider(
      create: (context) => MemoryCubit(xSize, ySize),
      child: GameScaffold(
        actions: [
          Builder(builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: InkWell(
                onTap: () {
                  context.read<MemoryCubit>().reset();
                },
                child: Image.asset(
                  "assets/reset_button.png",
                  width: 48,
                ),
              ),
            );
          }),
        ],
        body: BlocBuilder<MemoryCubit, AppState>(
          builder: (context, state) {
            if (state is MemoryInitialized) {
              MemoryField memoryField = state.memoryField;
              return SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    for (int y = 0; y < memoryField.field.length; y++)
                      for (int x = 0; x < memoryField.field[y].length; x++)
                        AnimatedPositioned(
                          duration: Duration(milliseconds: 300),
                          top: (192 / 2) * y,
                          left: x * 128,
                          width: 128,
                          child: MemoryCardWidget(
                            fileName: memoryField.field[y][x].fileName,
                            open: memoryField.field[y][x].open,
                            onTap: memoryField.field[y][x].solved
                                ? null
                                : state.playActive
                                    ? () {
                                        context
                                            .read<MemoryCubit>()
                                            .toggleField(x, y);
                                      }
                                    : null,
                          ),
                        ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
