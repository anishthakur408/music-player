import 'package:on_audio_query/on_audio_query.dart' as on_audio_query;

class SongModel {
  final int id;
  final String title;
  final String artist;
  final String album;
  final int duration; // in milliseconds
  final String data; // file path
  final String? albumArt;
  final String displayName;
  final String? genre;
  final int size;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.data,
    this.albumArt,
    required this.displayName,
    this.genre,
    required this.size,
  });

  // Convert duration from milliseconds to readable format (mm:ss)
  String get formattedDuration {
    final minutes = (duration / 60000).floor();
    final seconds = ((duration % 60000) / 1000).floor();
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get artist name, fallback to "Unknown Artist"
  String get artistName {
    if (artist.isEmpty || artist == '<unknown>') {
      return 'Unknown Artist';
    }
    return artist;
  }

  // Get song title, fallback to display name
  String get songTitle {
    if (title.isEmpty || title == '<unknown>') {
      return displayName.split('.').first; // Remove file extension
    }
    return title;
  }

  // Get album name, fallback to "Unknown Album"
  String get albumName {
    if (album.isEmpty || album == '<unknown>') {
      return 'Unknown Album';
    }
    return album;
  }

  // Check if album name is valid
  bool get hasValidAlbum {
    return album.isNotEmpty && album != '<unknown>';
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'data': data,
      'albumArt': albumArt,
      'displayName': displayName,
      'genre': genre,
      'size': size,
    };
  }

  // Create from JSON
  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'],
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      album: json['album'] ?? '',
      duration: json['duration'] ?? 0,
      data: json['data'] ?? '',
      albumArt: json['albumArt'],
      displayName: json['displayName'] ?? '',
      genre: json['genre'],
      size: json['size'] ?? 0,
    );
  }

  // Create from AudioQuery object
  factory SongModel.fromAudioQuery(on_audio_query.SongModel audioQuerySong) {
    return SongModel(
      id: audioQuerySong.id,
      title: audioQuerySong.title,
      artist: audioQuerySong.artist ?? '',
      album: audioQuerySong.album ?? '',
      duration: audioQuerySong.duration ?? 0,
      data: audioQuerySong.data,
      albumArt: null, // Artwork is queried separately
      displayName: audioQuerySong.displayName,
      genre: audioQuerySong.genre,
      size: audioQuerySong.size,
    );
  }

  @override
  String toString() {
    return 'SongModel{title: $title, artist: $artist, duration: $formattedDuration}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SongModel &&
        other.id == id &&
        other.data == data;
  }

  @override
  int get hashCode {
    return id.hashCode ^ data.hashCode;
  }
}
