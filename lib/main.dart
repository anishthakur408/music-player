import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
// import 'dart:math' as math;

import 'screens/splash_screen.dart';
// import 'screens/main_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/library_screen.dart';

// The following imports are not in the user provided main.dart but
// they are necessary for the other files to work
import 'widgets/glass_card.dart';
import 'widgets/circular_progress_painter.dart';
import 'services/audio_service.dart';
import 'services/music_scanner.dart';
import 'models/song_model.dart';


void main() {
  runApp(MusicApp());
}

class MusicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MYUSIC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'SF Pro Display',
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
