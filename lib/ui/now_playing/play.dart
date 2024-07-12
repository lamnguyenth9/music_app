import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3/data/model/song.dart';
import 'package:mp3/ui/now_playing/audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});
  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(playingSong: playingSong, songs: songs);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.playingSong, required this.songs});
  final Song playingSong;
  final List<Song> songs;
  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageanimationController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  late double _currentAnimationPosition;
  bool _iShuffle = false;
  late LoopMode _loopMode;
  @override
  void initState() {
    super.initState();
    _loopMode = LoopMode.off;
    _currentAnimationPosition = 0;
    _song = widget.playingSong;
    _imageanimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 12000));
    _audioPlayerManager = AudioPlayerManager();
    if(_audioPlayerManager.songUrl.compareTo(_song.source)!=0){
      _audioPlayerManager.upateSongUrl(_song.source);
      _audioPlayerManager.repare(isNewSong: true);
    }else{
      _audioPlayerManager.repare();
    }
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
  }

  @override
  void dispose() {
    
    _imageanimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const delta = 100;
    final radius = (width - delta) / 2;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Now Playing"),
        trailing: IconButton(
          icon: Icon(Icons.more_horiz),
          onPressed: () {},
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                _song.album,
              ),
              const Text('_ ___ _'),
              const SizedBox(
                height: 10,
              ),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0)
                    .animate(_imageanimationController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/tool.png',
                    image: _song.image,
                    width: width - delta,
                    height: width - delta,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/tool.png',
                        width: width - delta,
                        height: width - delta,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 18, bottom: 8),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.share_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          )),
                      Column(
                        children: [
                          Text(_song.title),
                          SizedBox(
                            height: 8,
                          ),
                          Text(_song.artist)
                        ],
                      ),
                      IconButton(
                          onPressed: () {}, icon: Icon(Icons.favorite_outline))
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 10, left: 24, right: 24, bottom: 12),
                child: _progressBar(),
              ),
              _mediaButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaButton() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              function: _setShuffle,
              icon: Icons.shuffle,
              color: _getShuffleColor(),
              size: 24),
          MediaButtonControl(
              function: _setPrevSong,
              icon: Icons.skip_previous,
              color: Colors.deepPurple,
              size: 24),
          _playButton(),
          MediaButtonControl(
              function: _setNextSong,
              icon: Icons.skip_next,
              color: Colors.deepPurple,
              size: 24),
          MediaButtonControl(
              function: _setRepeatOption,
              icon: _repeatingIcon(),
              color: _gerRepeatingIconColor(),
              size: 24)
        ],
      ),
    );
  }

  void _setRepeatOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  IconData _repeatingIcon() {
    return switch (_loopMode) {
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat
    };
  }

  Color? _gerRepeatingIconColor() {
    return _loopMode == LoopMode.off ? Colors.grey : Colors.deepPurple;
  }

  void _setNextSong() {
    if (_iShuffle) {
      var randm = Random();
      _selectedItemIndex = randm.nextInt(widget.songs.length);
    } else if (_selectedItemIndex < widget.songs.length - 1) {
      ++_selectedItemIndex;
    } else if (_loopMode == LoopMode.all &&
        _selectedItemIndex == widget.songs.length - 1) {
      _selectedItemIndex = 0;
    }
    if (_selectedItemIndex > widget.songs.length) {
      _selectedItemIndex = _selectedItemIndex % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.upateSongUrl(nextSong.source);
    _resetRotationAnim();
    setState(() {
      _song = nextSong;
    });
  }

  void _playRotationAnimation() {
    _imageanimationController.forward(from: _currentAnimationPosition);
    _imageanimationController.repeat();
  }

  void _pauseRotationAnim() {
    _stopRotationAnim();
    _currentAnimationPosition = _imageanimationController.value;
  }

  void _stopRotationAnim() {
    _imageanimationController.stop();
  }

  void _resetRotationAnim() {
    _currentAnimationPosition = 0;
    _imageanimationController.value = _currentAnimationPosition;
  }

  void _setPrevSong() {
    if (_iShuffle) {
      var randm = Random();
      _selectedItemIndex = randm.nextInt(widget.songs.length);
    } else if (_selectedItemIndex > 0) {
      --_selectedItemIndex;
    } else if (_loopMode == LoopMode.all && _selectedItemIndex == 0) {
      _selectedItemIndex = widget.songs.length - 1;
    }
    if (_selectedItemIndex < 0) {
      _selectedItemIndex = (-1 * _selectedItemIndex) % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.upateSongUrl(nextSong.source);
    _resetRotationAnim();
    setState(() {
      _song = nextSong;
    });
  }

  void _setShuffle() {
    setState(() {
      _iShuffle = !_iShuffle;
    });
  }

  Color? _getShuffleColor() {
    return _iShuffle ? Colors.deepPurple : Colors.grey;
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return ProgressBar(
          progress: progress,
          total: total,
          buffered: buffered,
          onSeek: _audioPlayerManager.player.seek,
          barHeight: 5,
          barCapShape: BarCapShape.round,
          baseBarColor: Colors.grey.withOpacity(0.3),
          progressBarColor: Colors.green,
          bufferedBarColor: Colors.grey.withOpacity(0.3),
          thumbColor: Colors.deepPurple,
          thumbGlowColor: Colors.green.withOpacity(0.3),
          thumbRadius: 10,
        );
      },
    );
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          _pauseRotationAnim();
          return Container(
            margin: EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.play();
              },
              icon: Icons.play_arrow,
              color: null,
              size: 48);
        } else if (processingState != ProcessingState.completed) {
          _playRotationAnimation();
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.pause();
                _pauseRotationAnim();
              },
              icon: Icons.pause,
              color: null,
              size: 48);
        } else {
          if (processingState == ProcessingState.completed) {
            _stopRotationAnim();
            _resetRotationAnim();
          }
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.seek(Duration.zero);
                _resetRotationAnim();
                _playRotationAnimation();
              },
              icon: Icons.replay,
              color: null,
              size: 48);
        }
      },
    );
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl(
      {super.key,
      required this.function,
      required this.icon,
      required this.color,
      required this.size});
  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;
  @override
  State<StatefulWidget> createState() {
    return _MediaButtonControlState();
  }
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
