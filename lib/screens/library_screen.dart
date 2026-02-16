import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../services/audio_service.dart';
import '../services/music_scanner.dart';
import '../models/song_model.dart';

class LibraryScreen extends StatefulWidget {
  final AudioPlayerService audioService;
  final MusicScanner musicScanner;

  const LibraryScreen({
    Key? key,
    required this.audioService,
    required this.musicScanner,
  }) : super(key: key);

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with TickerProviderStateMixin {
  int _selectedTab = 0;
  List<SongModel> _displayedSongs = [];
  List<String> _artists = [];
  List<String> _albums = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLibraryData();
  }

  void _loadLibraryData() {
    setState(() {
      _displayedSongs = widget.musicScanner.allSongs;
      _artists = widget.musicScanner.getAllArtists();
      _albums = widget.musicScanner.getAllAlbums();
    });
  }

  Future<void> _refreshLibrary() async {
    try {
      await widget.musicScanner.refreshLibrary();
      _loadLibraryData();
      _showSuccessMessage('Library refreshed successfully!');
    } catch (e) {
      _showErrorMessage('Failed to refresh library: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _searchSongs(String query) async {
    if (query.isEmpty) {
      _loadLibraryData();
      return;
    }

    final results = await widget.musicScanner.searchSongs(query);
    setState(() {
      _searchQuery = query;
      _displayedSongs = results;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(child: _buildTabContent()),
            _buildLibraryStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Your Library',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          Row(
            children: [
              GlassButton(
                width: 50,
                height: 50,
                padding: EdgeInsets.all(12),
                onTap: _refreshLibrary,
                child: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: GlassCard(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: TextField(
          controller: _searchController,
          onChanged: _searchSongs,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search songs, artists, or albums...',
            hintStyle: TextStyle(color: AppColors.textMuted),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: GlassCard(
        padding: EdgeInsets.all(1),
        borderRadius: 15,
        child: Row(
          children: [
            Expanded(
              child: GlassButton(
                borderRadius: 20,
                isPressed: _selectedTab == 0,
                onTap: () => setState(() => _selectedTab = 0),
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Songs',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 0 ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: GlassButton(
                borderRadius: 20,
                isPressed: _selectedTab == 1,
                onTap: () => setState(() => _selectedTab = 1),
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Artists',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 1 ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: GlassButton(
                borderRadius: 20,
                isPressed: _selectedTab == 2,
                onTap: () => setState(() => _selectedTab = 2),
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Albums',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 2 ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildSongList();
      case 1:
        return _buildArtistList();
      case 2:
        return _buildAlbumList();
      default:
        return Center(child: Text('Error: Unknown tab', style: TextStyle(color: AppColors.red)));
    }
  }

  Widget _buildSongList() {
    return ListView.builder(
      itemCount: _displayedSongs.length,
      itemBuilder: (context, index) {
        final song = _displayedSongs[index];
        return GlassListTile(
          onTap: () => widget.audioService.playSong(song, newPlaylist: _displayedSongs),
          leading: CircularGlassContainer(
            size: 50,
            child: Icon(Icons.music_note_rounded, color: AppColors.primary),
          ),
          title: Text(
            song.songTitle,
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            song.artistName,
            style: TextStyle(color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            song.formattedDuration,
            style: TextStyle(color: AppColors.textMuted),
          ),
        );
      },
    );
  }

  Widget _buildArtistList() {
    return ListView.builder(
      itemCount: _artists.length,
      itemBuilder: (context, index) {
        final artist = _artists[index];
        return GlassListTile(
          onTap: () async {
            final songs = await widget.musicScanner.getSongsByArtist(artist);
            widget.audioService.setPlaylist(songs);
            // TODO: Navigate to a new screen showing artist's songs
          },
          leading: CircularGlassContainer(
            size: 50,
            child: Icon(Icons.person_rounded, color: AppColors.primary),
          ),
          title: Text(
            artist,
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${widget.musicScanner.allSongs.where((s) => s.artist == artist).length} songs',
            style: TextStyle(color: AppColors.textMuted),
          ),
        );
      },
    );
  }

  Widget _buildAlbumList() {
    return ListView.builder(
      itemCount: _albums.length,
      itemBuilder: (context, index) {
        final album = _albums[index];
        final albumSongs = widget.musicScanner.allSongs.where((s) => s.album == album).toList();
        return GlassListTile(
          onTap: () {
            widget.audioService.setPlaylist(albumSongs);
            // TODO: Navigate to a new screen showing album songs
          },
          leading: CircularGlassContainer(
            size: 50,
            child: Icon(Icons.album_rounded, color: AppColors.primary),
          ),
          title: Text(
            album,
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${albumSongs.length} songs',
            style: TextStyle(color: AppColors.textMuted),
          ),
        );
      },
    );
  }

  Widget _buildLibraryStats() {
    final stats = widget.musicScanner.getLibraryStats();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: GlassCard(
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            SizedBox(height: 5),
            Text(value, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
