import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning/game_scaffold.dart';
import 'package:learning/set_cubit.dart';
import 'package:learning/utils/bloc_utils.dart';

int rows = 7;
int columns = 5;

class LeftRightGame extends StatelessWidget {
  const LeftRightGame({super.key});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      body: BlocProvider(
        create: (context) => SetCubit(rows * columns, 2),
        child: BlocBuilder<SetCubit, AppState>(
          builder: (context, state) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  child: Image.asset(
                    "assets/682r.jpg",
                  ),
                ),
                if (state is SetInitialized)
                  Positioned(
                      top: 16,
                      left: 32,
                      right: 32,
                      bottom: 16,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ElementField(
                              elements: state.leftElements,
                            ),
                          ),
                          Expanded(
                              child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 80, bottom: 150),
                              child: Container(
                                width: 10,
                                color: Colors.grey,
                              ),
                            ),
                          )),
                          Expanded(
                            flex: 2,
                            child: ElementField(
                              elements: state.rightElements,
                            ),
                          ),
                        ],
                      )),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          response: SetResponse.left,
                          text: "Links",
                          onTap: state is SetInitialized &&
                                  state is! SetResponseInitialized
                              ? () {
                                  context.read<SetCubit>().processResponse(
                                      SetResponse.left, state.challenge);
                                }
                              : null,
                        ),
                      ),
                      Expanded(
                        child: ActionButton(
                          response: SetResponse.equal,
                          text: "=",
                          onTap: state is SetInitialized &&
                                  state is! SetResponseInitialized
                              ? () {
                                  context.read<SetCubit>().processResponse(
                                      SetResponse.equal, state.challenge);
                                }
                              : null,
                        ),
                      ),
                      Expanded(
                        child: ActionButton(
                          response: SetResponse.right,
                          text: "Rechts",
                          onTap: state is SetInitialized &&
                                  state is! SetResponseInitialized
                              ? () {
                                  context.read<SetCubit>().processResponse(
                                      SetResponse.right, state.challenge);
                                }
                              : null,
                        ),
                      )
                    ],
                  ),
                ),
                if (state is SetResponseInitialized)
                  Positioned(
                      width: 512,
                      height: 256,
                      child: Stack(
                        children: [
                          Image.asset("assets/result.png"),
                          Positioned(
                            left: 166,
                            top: 30,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: Icon(
                                state.correct
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 180,
                                color:
                                    state.correct ? Colors.green : Colors.red,
                              ),
                            ),
                          )
                        ],
                      )),
                if (state is SetResponseInitialized) ...[
                  Positioned(
                    left: 64,
                    top: 80,
                    width: 256,
                    child: ScoreWidget(score: "${state.leftCount}"),
                  ),
                  Positioned(
                    right: 64,
                    top: 80,
                    width: 256,
                    child: ScoreWidget(score: "${state.rightCount}"),
                  ),
                ],
                if (state is SetInitialized)
                  Positioned(
                      top: 32,
                      left: 0,
                      right: 0,
                      child: Text(
                        state.status,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 32),
                      ))
              ],
            );
          },
        ),
      ),
    );
  }
}

class ScoreWidget extends StatelessWidget {
  final String score;

  const ScoreWidget({
    Key? key,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Image.asset("assets/score2.png"),
      Text(
        score,
        style: TextStyle(color: Colors.white, fontSize: 96),
      )
    ]);
  }
}

class ElementField extends StatelessWidget {
  final List<SetElement> elements;
  const ElementField({
    Key? key,
    required this.elements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: columns,
      children: elements
          .map((e) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: e.color,
                      boxShadow: e == noElement
                          ? null
                          : [
                              BoxShadow(
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  offset: Offset(4, 4))
                            ]),
                  width: 48,
                  height: 48,
                ),
              ))
          .toList(),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final SetResponse response;
  final Function()? onTap;

  const ActionButton({
    Key? key,
    required this.text,
    required this.onTap,
    required this.response,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Ink(
        decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: InkWell(
          splashColor: Colors.blueAccent,
          highlightColor: Colors.blueAccent,
          onTap: onTap,
          child: Container(
            height: 128,
            color: Colors.black38,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (response == SetResponse.left ||
                    response == SetResponse.right)
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(
                        response == SetResponse.right ? 0 : pi),
                    child: Icon(
                      Icons.back_hand,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
