import 'dart:async';

import 'package:mp3/data/model/song.dart';
import 'package:mp3/data/repository/repository.dart';

class MusicAppViewModel{
  StreamController<List<Song>> songStream = StreamController();

  void loadSongs(){
    final repository= DefaultRepository();
    repository.loadData().then((value) => songStream.add(value!));
  }
}