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
        GlassButton(
          width: 50,
          height: 50,
          padding: EdgeInsets.all(12),
          onTap: () {
            // Could implement drawer or back navigation
          },
          child: Icon(
            Icons.menu_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        Text(
          'Now Playing',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        GlassButton(
          width: 50,
          height: 50,
          padding: EdgeInsets.all(12),
          onTap: () {
            // Could implement settings or more options
          },
          child: Icon(
            Icons.more_horiz_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
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
              Icons.music_off_rounded,
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

          SizedBox(height: 40),

          // Progress and time
          _buildProgressSection(),

          SizedBox(height: 30),

          // Control buttons
          _buildControlButtons(),

          SizedBox(height: 30),

          // Additional controls
          _buildAdditionalControls(),
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

        // Rotating disc
        RotatingDiscWidget(
          size: 200,
          isRotating: _isPlaying,
          backgroundColor: AppColors.primary,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TONE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 4),
              Container(
                width: 30,
                height: 2,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ],
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

        SizedBox(height: 10),

        // Progress slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.glassBackground,
            thumbColor: AppColors.primary,
          ),
          child: Slider(
            value: _currentProgress.clamp(0.0, 1.0),
            onChanged: (value) {
              final position = Duration(
                milliseconds: (value * _totalDuration.inMilliseconds).round(),
              );
              widget.audioService.seek(position);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        GlassButton(
          width: 60,
          height: 60,
          padding: EdgeInsets.all(15),
          onTap: () => widget.audioService.skipToPrevious(),
          child: Icon(
            Icons.skip_previous_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),

        SizedBox(width: 20),

        // Play/Pause button
        GlassButton(
          width: 80,
          height: 80,
          padding: EdgeInsets.all(20),
          onTap: () => widget.audioService.togglePlayPause(),
          child: Icon(
            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: AppColors.primary,
            size: 36,
          ),
        ),

        SizedBox(width: 20),

        // Next button
        GlassButton(
          width: 60,
          height: 60,
          padding: EdgeInsets.all(15),
          onTap: () => widget.audioService.skipToNext(),
          child: Icon(
            Icons.skip_next_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Favorite button
        GlassButton(
          width: 50,
          height: 50,
          padding: EdgeInsets.all(12),
          onTap: () {
            // TODO: Implement favorite functionality
          },
          child: Icon(
            Icons.favorite_rounded,
            color: AppColors.red,
            size: 24,
          ),
        ),

        // Lyrics section
        Column(
          children: [
            Text(
              'Playing from Library',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${widget.musicScanner.allSongs.length} songs available',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),

        // Shuffle button
        GlassButton(
          width: 50,
          height: 50,
          padding: EdgeInsets.all(12),
          onTap: () => widget.audioService.toggleShuffle(),
          child: Icon(
            Icons.shuffle_rounded,
            color: widget.audioService.isShuffleEnabled
                ? AppColors.primary
                : AppColors.textMuted,
            size: 24,
          ),
        ),
      ],
    );
  }
}
