import 'package:on_audio_query/on_audio_query.dart' as on_audio_query;
import 'dart:typed_data';
import '../models/song_model.dart';
import '../utils/permissions.dart';

class MusicScanner {
  static final MusicScanner _instance = MusicScanner._internal();
  factory MusicScanner() => _instance;
  MusicScanner._internal();

  final on_audio_query.OnAudioQuery _audioQuery = on_audio_query.OnAudioQuery();
  List<SongModel> _allSongs = [];
  bool _isScanning = false;

  /// Get all songs (cached)
  List<SongModel> get allSongs => _allSongs;

  /// Check if currently scanning
  bool get isScanning => _isScanning;

  /// Scan device for music files
  Future<List<SongModel>> scanForMusic({bool forceRefresh = false}) async {
    // Return cached data if available and not forcing refresh
    if (_allSongs.isNotEmpty && !forceRefresh) {
      return _allSongs;
    }

    _isScanning = true;

    try {
      // Check permissions first
      bool hasPermission = await PermissionHelper.checkAndRequestPermission();
      if (!hasPermission) {
        throw Exception('Storage permission not granted');
      }

      // Query all audio files from device
      List<on_audio_query.SongModel> audioFiles = await _audioQuery.querySongs(
        sortType: on_audio_query.SongSortType.TITLE,
        orderType: on_audio_query.OrderType.ASC_OR_SMALLER,
        uriType: on_audio_query.UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Convert to our custom SongModel and filter valid files
      _allSongs = audioFiles
          .map((song) => SongModel.fromAudioQuery(song))
          .where(_isValidMusicFile)
          .toList();

      print('Found ${_allSongs.length} music files');
      return _allSongs;

    } catch (e) {
      print('Error scanning for music: $e');
      _allSongs = [];
      rethrow;
    } finally {
      _isScanning = false;
    }
  }

  /// Get songs by artist
  Future<List<SongModel>> getSongsByArtist(String artistName) async {
    if (_allSongs.isEmpty) {
      await scanForMusic();
    }

    return _allSongs
        .where((song) =>
    song.artist.toLowerCase() == artistName.toLowerCase())
        .toList();
  }

  /// Get songs by album
  Future<List<SongModel>> getSongsByAlbum(String albumName) async {
    if (_allSongs.isEmpty) {
      await scanForMusic();
    }

    return _allSongs
        .where((song) =>
    song.album.toLowerCase() == albumName.toLowerCase())
        .toList();
  }

  /// Search songs by query
  Future<List<SongModel>> searchSongs(String query) async {
    if (_allSongs.isEmpty) {
      await scanForMusic();
    }

    if (query.isEmpty) return _allSongs;

    final lowerQuery = query.toLowerCase();
    return _allSongs.where((song) =>
    song.title.toLowerCase().contains(lowerQuery) ||
        song.artist.toLowerCase().contains(lowerQuery) ||
        song.album.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Get all unique artists
  List<String> getAllArtists() {
    final artists = _allSongs
        .map((song) => song.artist)
        .where((artist) => artist.isNotEmpty && artist != 'Unknown Artist')
        .toSet()
        .toList();

    artists.sort();
    return artists;
  }

  /// Get all unique albums
  List<String> getAllAlbums() {
    final albums = _allSongs
        .map((song) => song.album)
        .where((album) => album.isNotEmpty && album != 'Unknown Album')
        .toSet()
        .toList();

    albums.sort();
    return albums;
  }

  /// Get album artwork
  Future<Uint8List?> getAlbumArt(int albumId) async {
    try {
      return await _audioQuery.queryArtwork(
        albumId,
        on_audio_query.ArtworkType.ALBUM,
        format: on_audio_query.ArtworkFormat.JPEG,
        size: 200,
      );
    } catch (e) {
      print('Error getting album art: $e');
      return null;
    }
  }

  /// Get recently played songs (you can implement your own logic)
  List<SongModel> getRecentlyPlayed() {
    // For now, return first 10 songs
    // In a real app, you'd track this in shared preferences
    return _allSongs.take(10).toList();
  }

  /// Get popular songs (you can implement your own logic)
  List<SongModel> getPopularSongs() {
    // For now, return songs sorted by size (larger files might be higher quality)
    final sortedSongs = List<SongModel>.from(_allSongs);
    sortedSongs.sort((a, b) => b.size.compareTo(a.size));
    return sortedSongs.take(20).toList();
  }

  /// Filter to check if file is a valid music file
  bool _isValidMusicFile(SongModel song) {
    // Filter out very short files (likely ringtones or notifications)
    if (song.duration < 30000) return false; // Less than 30 seconds

    // Filter out very small files
    if (song.size < 1000000) return false; // Less than 1MB

    // Check file extension
    final validExtensions = ['.mp3', '.wav', '.m4a', '.aac', '.ogg', '.flac'];
    final fileName = song.data.toLowerCase();

    return validExtensions.any((ext) => fileName.endsWith(ext));
  }

  /// Refresh music library
  Future<void> refreshLibrary() async {
    await scanForMusic(forceRefresh: true);
  }

  /// Get total music duration
  String getTotalDuration() {
    int totalMs = _allSongs.fold(0, (sum, song) => sum + song.duration);
    int totalMinutes = (totalMs / 60000).floor();
    int hours = (totalMinutes / 60).floor();
    int minutes = totalMinutes % 60;

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }

  /// Get library statistics
  Map<String, dynamic> getLibraryStats() {
    return {
      'totalSongs': _allSongs.length,
      'totalArtists': getAllArtists().length,
      'totalAlbums': getAllAlbums().length,
      'totalDuration': getTotalDuration(),
    };
  }
}
