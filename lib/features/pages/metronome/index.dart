
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/data/services/metronome.dart';
import 'package:m/features/pages/metronome/metronome_view.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {
  final MetronomeService metronomeService = MetronomeService.to;

  double get bpm => metronomeService.bpm.value;
  Rhythm get selectedRhythm => metronomeService.selectedRhythm.value;
  bool get isPlaying => metronomeService.isPlaying.value;
  int get count => metronomeService.count.value;
  int get currentBeat =>  metronomeService.currentBeat;

  MetronomeSound get selectedMetronomeSound => metronomeService.selectedMetronomeSound.value;

  set selectedMetronomeSound(MetronomeSound value) {
    metronomeService.selectedMetronomeSound.value = value;
  }

  set bpm(double value) {
    metronomeService.bpm.value = value;
  }

  set selectedRhythm(Rhythm value) {
    metronomeService.selectedRhythm.value = value;
  }

  set isPlaying(bool value) {
    metronomeService.isPlaying.value = value;
  }

  void timeLoop() { 
     metronomeService.switchPlay();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('节拍器'.tr),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(StarThemeData.spacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            const MetronomeView(),
             
             Obx(() => PopupMenuButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(selectedRhythm.label,style:const TextStyle(fontSize: 32),),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  itemBuilder: (context) => Rhythm.values
                      .map((e) => PopupMenuItem(value: e, child: Text(e.label)))
                      .toList(),
                  onSelected: (value) {
                    selectedRhythm = value;
                  })),
             Obx(() => Row(
                children: [ 
                  IconButton(icon: const Icon(Icons.add),onPressed: (){
                    bpm = bpm + 1;
                  }), 
                  Expanded(
                    child: Slider(
                      value: bpm,
                      min: MetronomeService.minBpm,
                      max: MetronomeService.maxBpm,
                      onChanged: (value) {
                        bpm = value;
                      },
                    ),
                  ),
                   IconButton(icon: const Icon(Icons.remove),onPressed: (){
                    bpm = bpm - 1;
                  }),
                ],
              )),
              Obx(()=>Text('${'BMP'.tr}${bpm.toInt()}',style:const TextStyle(fontSize: 62),)),
             Obx(() => IconButton(
                icon: Icon(isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_sharp),
                iconSize: 180,
                onPressed: () {
                 timeLoop();
                },
              )),
              Obx(()=>PopupMenuButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('声音：',style: TextStyle(fontSize: 22),),
                    Text(selectedMetronomeSound.label,style:const TextStyle(fontSize: 32),),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
                itemBuilder: (context) => MetronomeSound.values
                      .map((e) => PopupMenuItem(value: e, child: Text(e.label)))
                      .toList(),
                  onSelected: (value) {
                     selectedMetronomeSound = value;
                  }))
            ],
          ),
        ),
      ),
    );
  }
}
