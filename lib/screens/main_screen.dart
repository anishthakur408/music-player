import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../services/audio_service.dart';
import '../services/music_scanner.dart';
import 'home_screen.dart';
import 'library_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final AudioPlayerService _audioService = AudioPlayerService();
  final MusicScanner _musicScanner = MusicScanner();

  SongModel? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isFavorite = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _audioService.init();

      _audioService.currentSongStream.listen((song) {
        if (!mounted) return;
        setState(() {
          _currentSong = song;
        });
      });

      _audioService.isPlayingStream.listen((playing) {
        if (!mounted) return;
        setState(() {
          _isPlaying = playing;
        });
      });

      _audioService.positionStream.listen((position) {
        if (!mounted) return;
        setState(() {
          _currentPosition = position;
        });
      });

      _audioService.durationStream.listen((duration) {
        if (!mounted) return;
        setState(() {
          _totalDuration = duration;
        });
      });

      await _scanForMusic();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scanForMusic() async {
    try {
      final songs = await _musicScanner.scanForMusic();
      if (!mounted) return;
      // Keep scanner cache warm for Home/Library; UI only needs loading state.
      setState(() {
        if (songs.isEmpty) {
          _currentSong = null;
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePreviousSong() async {
    await _audioService.skipToPrevious();
  }

  Future<void> _handleNextSong() async {
    await _audioService.skipToNext();
  }

  void _seekTo(double progress) {
    final seconds = (_totalDuration.inSeconds * progress).round();
    _audioService.seek(Duration(seconds: seconds));
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Scanning your music...'),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context) {
    final song = _currentSong;
    if (song == null) {
      return const SizedBox.shrink();
    }

    final progress = _totalDuration.inSeconds > 0
        ? _currentPosition.inSeconds / _totalDuration.inSeconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.music_note),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _handlePreviousSong,
                icon: const Icon(Icons.skip_previous),
              ),
              IconButton(
                onPressed: () => _audioService.togglePlayPause(),
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              IconButton(
                onPressed: _handleNextSong,
                icon: const Icon(Icons.skip_next),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
              ),
            ],
          ),
          Slider(
            min: 0,
            max: 1,
            value: progress.clamp(0.0, 1.0),
            onChanged: _seekTo,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_currentPosition)),
                Text(_formatDuration(_totalDuration)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(audioService: _audioService, musicScanner: _musicScanner),
          LibraryScreen(audioService: _audioService, musicScanner: _musicScanner),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentSong != null) _buildMiniPlayer(context),
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.library_music), label: 'Library'),
            ],
          ),
        ],
      ),
    );
  }
}
