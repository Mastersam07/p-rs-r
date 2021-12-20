import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AppAudioPlayer extends StatefulWidget {
  final File audioFile;

  const AppAudioPlayer({Key? key, required this.audioFile}) : super(key: key);
  @override
  _AppAudioPlayerState createState() => _AppAudioPlayerState();
}

class _AppAudioPlayerState extends State<AppAudioPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Listen to errors during playback
    _audioPlayer.playbackEventStream.listen((event) {
      print(event.processingState);
    }, onError: (e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    }, onDone: () {
      print("PLAYING DONE");
      setState(() {
        _audioPlayer.seek(Duration.zero);
      });
    });
    // Try to load audio from a source and catch any errors.
    try {
      print("LOADING AUDIO SOURCE");
      await _audioPlayer.setFilePath(widget.audioFile.path);
      print("DONE LOADING AUDIO SOURCE");
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: Color(0xFFDCF8C6),
      ),
      child: Row(
        children: [
          CircleAvatar(
            child: IconButton(
              onPressed: () {
                if (_audioPlayer.playerState.processingState ==
                    ProcessingState.completed) {
                  _audioPlayer.seek(Duration.zero);
                } else if (_audioPlayer.playing) {
                  setState(() {
                    _audioPlayer.pause();
                  });
                } else {
                  setState(() {
                    _audioPlayer.play();
                  });
                }
              },
              icon: Icon(_audioPlayer.playing
                  ? Icons.pause
                  : Icons.play_arrow_rounded),
            ),
          ),
          StreamBuilder<Duration>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final audioDurationInSeconds =
                    _audioPlayer.duration?.inSeconds ?? 0;
                return Expanded(
                  child: Slider(
                    inactiveColor: Colors.teal,
                    activeColor: Colors.teal[900],
                    value: snapshot.data?.inSeconds.toDouble() ?? 0.00,
                    max: audioDurationInSeconds.toDouble(),
                    min: 0.00,
                    onChanged: (value) {
                      setState(() {
                        _audioPlayer.seek(Duration(seconds: value.floor()));
                      });
                    },
                    onChangeEnd: (_) => _audioPlayer.seek(Duration.zero),
                  ),
                );
              })
        ],
      ),
    );
  }
}
