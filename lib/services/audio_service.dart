import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import 'dart:async';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Current playback state
  SongModel? _currentSong;
  List<SongModel> _playlist = [];
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;

  // Stream controllers for UI updates
  final StreamController<SongModel?> _currentSongController =
  StreamController<SongModel?>.broadcast();
  final StreamController<bool> _isPlayingController =
  StreamController<bool>.broadcast();
  final StreamController<Duration> _positionController =
  StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController =
  StreamController<Duration>.broadcast();

  // Getters
  SongModel? get currentSong => _currentSong;
  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _player.playing;
  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;
  AudioPlayer get player => _player;

  // Streams for UI
  Stream<SongModel?> get currentSongStream => _currentSongController.stream;
  Stream<bool> get isPlayingStream => _isPlayingController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;

  /// Initialize the audio service
  Future<void> init() async {
    // Listen to player state changes
    _player.playingStream.listen((playing) {
      _isPlayingController.add(playing);
    });

    // Listen to position changes
    _player.positionStream.listen((position) {
      _positionController.add(position);
    });

    // Listen to duration changes
    _player.durationStream.listen((duration) {
      if (duration != null) {
        _durationController.add(duration);
      }
    });

    // Listen to sequence state changes (for next/previous)
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null) {
        _currentIndex = sequenceState.currentIndex;
        if (_currentIndex < _playlist.length) {
          _currentSong = _playlist[_currentIndex];
          _currentSongController.add(_currentSong);
        }
      }
    });

    // Listen to player completion
    _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        // Auto play next song if available
        if (_currentIndex < _playlist.length - 1 || _loopMode != LoopMode.off) {
          // Let just_audio handle the next song based on loop mode
        }
      }
    });
  }

  /// Play a single song
  Future<void> playSong(SongModel song, {List<SongModel>? newPlaylist}) async {
    try {
      // If new playlist is provided, update the playlist
      if (newPlaylist != null) {
        _playlist = newPlaylist;
        _currentIndex = _playlist.indexOf(song);
      } else if (_playlist.isEmpty) {
        // If no playlist exists, create one with just this song
        _playlist = [song];
        _currentIndex = 0;
      } else {
        // Update current index in existing playlist
        _currentIndex = _playlist.indexOf(song);
        if (_currentIndex == -1) {
          // Song not in playlist, add it and play
          _playlist.add(song);
          _currentIndex = _playlist.length - 1;
        }
      }

      _currentSong = song;
      _currentSongController.add(_currentSong);

      // Create playlist for just_audio
      final audioSources = _playlist.map((song) =>
          AudioSource.file(song.data)).toList();

      final playlist = ConcatenatingAudioSource(children: audioSources);

      // Set the playlist and play from current index
      await _player.setAudioSource(playlist, initialIndex: _currentIndex);
      await _player.play();

      print('Now playing: ${song.title} by ${song.artist}');
    } catch (e) {
      print('Error playing song: $e');
      throw Exception('Failed to play song: ${song.title}');
    }
  }

  /// Play/pause toggle
  Future<void> togglePlayPause() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (e) {
      print('Error toggling play/pause: $e');
    }
  }

  /// Play
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      print('Error playing: $e');
    }
  }

  /// Pause
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      print('Error pausing: $e');
    }
  }

  /// Stop
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      print('Error stopping: $e');
    }
  }

  /// Skip to next song
  Future<void> skipToNext() async {
    try {
      if (_playlist.isNotEmpty) {
        await _player.seekToNext();
      }
    } catch (e) {
      print('Error skipping to next: $e');
    }
  }

  /// Skip to previous song
  Future<void> skipToPrevious() async {
    try {
      if (_playlist.isNotEmpty) {
        await _player.seekToPrevious();
      }
    } catch (e) {
      print('Error skipping to previous: $e');
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  /// Toggle shuffle mode
  Future<void> toggleShuffle() async {
    try {
      _isShuffleEnabled = !_isShuffleEnabled;
      await _player.setShuffleModeEnabled(_isShuffleEnabled);
    } catch (e) {
      print('Error toggling shuffle: $e');
    }
  }

  /// Toggle loop mode
  Future<void> toggleLoopMode() async {
    try {
      switch (_loopMode) {
        case LoopMode.off:
          _loopMode = LoopMode.one;
          break;
        case LoopMode.one:
          _loopMode = LoopMode.all;
          break;
        case LoopMode.all:
          _loopMode = LoopMode.off;
          break;
      }
      await _player.setLoopMode(_loopMode);
    } catch (e) {
      print('Error toggling loop mode: $e');
    }
  }

  /// Set playlist and play from specific index
  Future<void> setPlaylist(List<SongModel> songs, {int initialIndex = 0}) async {
    try {
      _playlist = songs;
      _currentIndex = initialIndex;

      if (_playlist.isNotEmpty) {
        _currentSong = _playlist[_currentIndex];
        _currentSongController.add(_currentSong);

        final audioSources = _playlist.map((song) =>
            AudioSource.file(song.data)).toList();

        final playlist = ConcatenatingAudioSource(children: audioSources);
        await _player.setAudioSource(playlist, initialIndex: _currentIndex);
      }
    } catch (e) {
      print('Error setting playlist: $e');
    }
  }

  /// Get current position
  Duration get currentPosition => _player.position;

  /// Get total duration
  Duration? get totalDuration => _player.duration;

  /// Get current position as percentage (0.0 to 1.0)
  double get positionPercentage {
    final duration = totalDuration;
    if (duration == null || duration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / duration.inMilliseconds;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _currentSongController.close();
    await _isPlayingController.close();
    await _positionController.close();
    await _durationController.close();
    await _player.dispose();
  }

  /// Clear playlist
  void clearPlaylist() {
    _playlist.clear();
    _currentIndex = 0;
    _currentSong = null;
    _currentSongController.add(null);
  }

  /// Add song to current playlist
  void addToPlaylist(SongModel song) {
    _playlist.add(song);
  }

  /// Remove song from playlist
  void removeFromPlaylist(int index) {
    if (index >= 0 && index < _playlist.length) {
      _playlist.removeAt(index);
      if (_currentIndex >= index) {
        _currentIndex = (_currentIndex - 1).clamp(0, _playlist.length - 1);
      }
    }
  }
}