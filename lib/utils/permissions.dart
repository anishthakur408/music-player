import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionHelper {

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need READ_MEDIA_AUDIO permission
      if (await _getAndroidVersion() >= 33) {
        return await Permission.audio.isGranted;
      } else {
        // For older Android versions, we need READ_EXTERNAL_STORAGE
        return await Permission.storage.isGranted;
      }
    }
    return true; // iOS doesn't need explicit storage permission for music
  }

  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      PermissionStatus status;

      // For Android 13+ (API 33+)
      if (await _getAndroidVersion() >= 33) {
        status = await Permission.audio.request();
      } else {
        // For older Android versions
        status = await Permission.storage.request();
      }

      return status.isGranted;
    }
    return true; // iOS doesn't need explicit permission
  }

  /// Check and request permission if needed
  static Future<bool> checkAndRequestPermission() async {
    // First check if we already have permission
    if (await hasStoragePermission()) {
      return true;
    }

    // If not, request permission
    return await requestStoragePermission();
  }

  /// Get permission status details
  static Future<PermissionStatus> getPermissionStatus() async {
    if (Platform.isAndroid) {
      if (await _getAndroidVersion() >= 33) {
        return await Permission.audio.status;
      } else {
        return await Permission.storage.status;
      }
    }
    return PermissionStatus.granted; // iOS default
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied() async {
    final status = await getPermissionStatus();
    return status.isPermanentlyDenied;
  }

  /// Open app settings if permission is permanently denied
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Handle permission result with user-friendly messages
  static String getPermissionMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return "Permission granted! You can now access your music.";
      case PermissionStatus.denied:
        return "Permission denied. Please allow storage access to play your music.";
      case PermissionStatus.permanentlyDenied:
        return "Permission permanently denied. Please enable it in app settings.";
      case PermissionStatus.restricted:
        return "Permission restricted. Cannot access storage.";
      case PermissionStatus.limited:
        return "Limited permission granted.";
      default:
        return "Unknown permission status.";
    }
  }

  /// Get Android API level
  static Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // This is a simplified check. In reality, you might want to use
      // device_info_plus package for more accurate version detection
      return 33; // Assume modern Android for now
    }
    return 0;
  }

  /// Show permission rationale dialog content
  static String getPermissionRationale() {
    return "This app needs access to your device storage to find and play your music files. "
        "Your privacy is important to us - we only access audio files and never share your data.";
  }

  /// Check if we need to show rationale (for Android)
  static Future<bool> shouldShowRequestPermissionRationale() async {
    if (Platform.isAndroid) {
      if (await _getAndroidVersion() >= 33) {
        return await Permission.audio.shouldShowRequestRationale;
      } else {
        return await Permission.storage.shouldShowRequestRationale;
      }
    }
    return false;
  }
}