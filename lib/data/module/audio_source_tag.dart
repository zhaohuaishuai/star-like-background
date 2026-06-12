import 'package:m/data/module/song.dart';

class AudioSourceTag {
  final SourceEnum source;
  final Song song;

  AudioSourceTag(this.source, this.song);
}

enum SourceEnum { network, local }
