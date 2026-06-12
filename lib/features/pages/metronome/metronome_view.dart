// ignore: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/data/services/metronome.dart';

class MetronomeView extends StatefulWidget {
  const MetronomeView({super.key});

  @override
  State<MetronomeView> createState() => _MetronomeViewState();
}

class _MetronomeViewState extends State<MetronomeView> {

  final MetronomeService metronomeService =MetronomeService.to;

  int get currentBeat => metronomeService.currentBeat;
  int get total => metronomeService.selectedRhythm.value.modeCount;
  bool get isPlaying => metronomeService.isPlaying.value  ;

  @override
  Widget build(BuildContext context) {
    return Obx(() =>isPlaying ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (int index){
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: AnimatedContainer( 
            duration: const Duration(milliseconds: 300),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: currentBeat - 1 == index   ? Colors.red : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    ):Container());
  }
}