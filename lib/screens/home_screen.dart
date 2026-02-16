import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/glass_card.dart';
import '../widgets/circular_progress_painter.dart';
import '../services/audio_service.dart';
import '../services/music_scanner.dart';
import '../models/song_model.dart';

class HomeScreen extends StatefulWidget {
  final AudioPlayerService audioService;
  final MusicScanner musicScanner;

  const HomeScreen({
    Key? key,
    required this.audioService,
    required this.musicScanner,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  SongModel? _currentSong;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _currentProgress = 0.0;

  late StreamSubscription _songSubscription;
  late StreamSubscription _playingSubscription;
  late StreamSubscription _positionSubscription;
  late StreamSubscription _durationSubscription;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to current song changes
    _songSubscription = widget.audioService.currentSongStream.listen((song) {
      setState(() {
        _currentSong = song;
      });
    });

    // Listen to playing state changes
    _playingSubscription = widget.audioService.isPlayingStream.listen((playing) {
      setState(() {
        _isPlaying = playing;
      });
    });

    // Listen to position changes
    _positionSubscription = widget.audioService.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
        _updateProgress();
      });
    });

    // Listen to duration changes
    _durationSubscription = widget.audioService.durationStream.listen((duration) {
      setState(() {
        _totalDuration = duration;
        _updateProgress();
      });
    });
  }

  void _updateProgress() {
    if (_totalDuration.inMilliseconds > 0) {
      _currentProgress = _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
    } else {
      _currentProgress = 0.0;
    }
  }

  @override
  void dispose() {
    _songSubscription.cancel();
    _playingSubscription.cancel();
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _playRandomSong() async {
    final songs = widget.musicScanner.allSongs;
    if (songs.isNotEmpty) {
      final randomSong = songs[DateTime.now().millisecond % songs.length];
      await widget.audioService.playSong(randomSong, newPlaylist: songs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              Expanded(
                child: _currentSong != null
                    ? _buildPlayerView()
                    : _buildEmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassCard(
            width: 120,
            height: 120,
            padding: EdgeInsets.all(30),
            child: Icon(
              Icons.music_off_outlined,
              size: 60,
              color: AppColors.textMuted,
            ),
          ),

          SizedBox(height: 30),

          Text(
            'No music playing',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'Choose a song from your library',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
            ),
          ),

          SizedBox(height: 30),

          GlassButton(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            onTap: _playRandomSong,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shuffle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Play Random Song',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerView() {
    return GlassCard(
      width: double.infinity,
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          // Song info
          _buildSongInfo(),

          SizedBox(height: 40),

          // Circular player
          _buildCircularPlayer(),



          // Additional controls

        ],
      ),
    );
  }

  Widget _buildSongInfo() {
    return Column(
      children: [
        Text(
          _currentSong!.title.toUpperCase(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: 8),

        Text(
          _currentSong!.artist,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        if (_currentSong!.hasValidAlbum) ...[
          SizedBox(height: 4),
          Text(
            _currentSong!.album,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildCircularPlayer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Progress ring
        Container(
          width: 280,
          height: 280,
          child: AnimatedProgressRing(
            progress: _currentProgress,
            size: 280,
            strokeWidth: 8,
            progressColor: AppColors.red,
            backgroundColor: AppColors.glassBackground,
          ),
        ),



        // Play button overlay (when paused)
        if (!_isPlaying)
          CircularGlassContainer(
            size: 80,
            backgroundColor: Colors.white.withOpacity(0.9),
            onTap: () => widget.audioService.togglePlayPause(),
            child: Icon(
              Icons.play_arrow_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // Time labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_currentPosition),
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatDuration(_totalDuration),
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Progress slider

      ],
    );
  }}