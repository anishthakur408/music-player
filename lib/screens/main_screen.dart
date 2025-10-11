import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../services/audio_service.dart';
import '../services/music_scanner.dart';
import '../models/song_model.dart';
import 'home_screen.dart';
import 'library_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final AudioPlayerService _audioService = AudioPlayerService();
  final MusicScanner _musicScanner = MusicScanner();

  SongModel? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = true;

  late AnimationController _miniPlayerController;
  late Animation<double> _miniPlayerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupMiniPlayerAnimation();
  }

  void _setupMiniPlayerAnimation() {
    _miniPlayerController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _miniPlayerAnimation = CurvedAnimation(
      parent: _miniPlayerController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize audio service
      await _audioService.init();

      // Listen to audio service streams
      _audioService.currentSongStream.listen((song) {
        setState(() {
          _currentSong = song;
        });

        if (song != null && _currentSong == null) {
          _miniPlayerController.forward();
        } else if (song == null && _currentSong != null) {
          _miniPlayerController.reverse();
        }
      });

      _audioService.isPlayingStream.listen((playing) {
        setState(() {
          _isPlaying = playing;
        });
      });

      // Scan for music in background
      _scanForMusic();

    } catch (e) {
      print('Error initializing services: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scanForMusic() async {
    try {
      await _musicScanner.scanForMusic();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error scanning music: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to scan music files. Please check permissions.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _miniPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      extendBody: true,
      body: GradientBackground(
        child: Stack(
          children: [
            // Main content
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                HomeScreen(
                  audioService: _audioService,
                  musicScanner: _musicScanner,
                ),
                LibraryScreen(
                  audioService: _audioService,
                  musicScanner: _musicScanner,
                ),
              ],
            ),

            // Mini player
            if (_currentSong != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 100, // Above bottom navigation
                child: AnimatedBuilder(
                  animation: _miniPlayerAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        (1 - _miniPlayerAnimation.value) * 100,
                      ),
                      child: Opacity(
                        opacity: _miniPlayerAnimation.value,
                        child: _buildMiniPlayer(),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassCard(
                width: 100,
                height: 100,
                padding: EdgeInsets.all(25),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 3,
                ),
              ),

              SizedBox(height: 30),

              Text(
                'Scanning your music...',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 10),

              Text(
                'This may take a moment',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    if (_currentSong == null) return SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Album art / Icon
            CircularGlassContainer(
              size: 50,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),

            SizedBox(width: 15),

            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentSong!.title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    _currentSong!.artist,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(width: 15),

            // Play/Pause button
            GlassButton(
              width: 50,
              height: 50,
              padding: EdgeInsets.all(12),
              onTap: () => _audioService.togglePlayPause(),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      margin: EdgeInsets.all(20),
      child: GlassCard(
        padding: EdgeInsets.symmetric(vertical: 8),
        borderRadius: 25,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
            ),
            _buildNavItem(
              icon: Icons.library_music_rounded,
              label: 'Library',
              index: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textMuted,
              size: 24,
            ),
            if (isSelected) ...[
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Extension for easy access to services from child screens
extension MainScreenContext on BuildContext {
  MainScreen? get mainScreen {
    return findAncestorWidgetOfExactType<MainScreen>();
  }
}
