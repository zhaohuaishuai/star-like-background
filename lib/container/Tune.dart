import 'package:get/get.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'dart:typed_data';
import 'dart:developer';
import 'package:flutter/src/foundation/constants.dart';

class Tune extends GetxController {
  late final FlutterAudioCapture audioRecorder;
  late final PitchDetector pitchDetectorDart;
  late final PitchHandler pitchupDart;
  final note = "".obs;
  final turnStatus = "Click on start".obs;
  late final RxDouble diffCents = 0.0.obs;
  final RxDouble diffFrequency = 0.0.obs;
  final isRecored = false.obs;
  final curPitch = 0.0.obs;
  final List<String> guitarNotes = ["E", "A", "D", "G", "B", "E"];

  @override
  void onInit() async {
    super.onInit();
    await requestMicrophonePermission();
    audioRecorder = FlutterAudioCapture();
    pitchDetectorDart = PitchDetector(44100, 2000);
    pitchupDart = PitchHandler(InstrumentType.guitar);
  }

  @override
  void onClose() {
    super.onClose();
    stopRecording();
  }

  startRecording() async {
    try {
      await audioRecorder.start(listener, error,
          sampleRate: 44100, bufferSize: 3000);
      note.value = "";
      turnStatus.value = "Play something";
      isRecored.value = true;
    } catch (err) {
      if (kDebugMode) {
        print("发生了错误");
      }
    }
  }

  stopRecording() async {
    await audioRecorder.stop();
    isRecored.value = false;
    resetState();
  }

  resetState() {
    note.value = "";
    turnStatus.value = "Click on start";
    diffCents.value = 0.0;
    diffFrequency.value = 0.0;

    curPitch.value = 0.0;
  }

  listener(dynamic obj) {
    var buffer = Float64List.fromList(obj.cast<double>());
    final List<double> audioSample = buffer.toList();
    final result = pitchDetectorDart.getPitch(audioSample);

    if (result.pitched) {
      final handledPitchResult = pitchupDart.handlePitch(result.pitch);
      curPitch.value = result.pitch;
      bool noteIsExist =
          guitarNotes.any((element) => element == handledPitchResult.note);
      if (!noteIsExist) {
        resetState();
        return;
      }
      ;

      note.value = handledPitchResult.note;
      turnStatus.value = handledPitchResult.tuningStatus.toString();
      diffCents.value = handledPitchResult.diffCents;
      diffFrequency.value = handledPitchResult.diffFrequency;

      log("diffCents:${handledPitchResult.diffCents}");
      log("diffFrequency:${handledPitchResult.diffFrequency}");
      log("note:$note");
      log("status:$turnStatus");
      log("result.pitch:${result.pitch}");
    } else {
      resetState();
    }
  }

  error(Object e) {
    if (kDebugMode) {
      print(e);
    }
  }

  Future<void> requestMicrophonePermission() async {
    var perstatus = await Permission.microphone.status;
    if (!perstatus.isGranted) {
      var result = await Permission.microphone.request();
      if (!result.isGranted) {
        // The user chose not to grant the permission, handle as appropriate.
      }
    }
  }
}

class TuneBinding implements Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put<Tune>(Tune());
  }
}
