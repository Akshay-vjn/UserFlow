import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userflow/core/services/remote_config_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

final forceUpdateServiceProvider = Provider<ForceUpdateService>((ref) {
  final remoteConfigService = ref.watch(remoteConfigServiceProvider);
  return ForceUpdateService(remoteConfigService);
});

enum UpdateStatus {
  noUpdateRequired,
  forceUpdateRequired,
}

class UpdateInfo {
  final UpdateStatus status;
  final String currentVersion;
  final String minimumVersion;
  final String message;
  final String storeUrl;

  UpdateInfo({
    required this.status,
    required this.currentVersion,
    required this.minimumVersion,
    required this.message,
    required this.storeUrl,
  });
}

class ForceUpdateService {
  final RemoteConfigService _remoteConfigService;

  ForceUpdateService(this._remoteConfigService);

  Future<UpdateInfo> checkForUpdate() async {
    try {
      // Fetch latest config values from Firebase
      await _remoteConfigService.refresh();
      
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Get remote config values
      final minimumVersion = _remoteConfigService.getMinimumVersion();
      final forceUpdateRequired = _remoteConfigService.getForceUpdateRequired();

      // Get platform-specific store URL
      final storeUrl = Platform.isAndroid
          ? _remoteConfigService.getAndroidStoreUrl()
          : _remoteConfigService.getIosStoreUrl();

      if (kDebugMode) {
        print('=== Force Update Check ===');
        print('Platform: ${Platform.isAndroid ? "Android" : Platform.isIOS ? "iOS" : "Other"}');
        print('Current Version: $currentVersion');
        print('Minimum Version: $minimumVersion');
        print('Force Update Required: $forceUpdateRequired');
      }

      // Check if force update is required (only based on minimum_version)
      if (forceUpdateRequired && _isVersionLower(currentVersion, minimumVersion)) {
        if (kDebugMode) {
          print('Result: FORCE UPDATE REQUIRED (below minimum version)');
          print('========================');
        }
        return UpdateInfo(
          status: UpdateStatus.forceUpdateRequired,
          currentVersion: currentVersion,
          minimumVersion: minimumVersion,
          message: _remoteConfigService.getUpdateMessage(),
          storeUrl: storeUrl,
        );
      }

      ///No update required
      if (kDebugMode) {
        print('Result: NO UPDATE REQUIRED (meets minimum version)');
        print('========================');
      }
      return UpdateInfo(
        status: UpdateStatus.noUpdateRequired,
        currentVersion: currentVersion,
        minimumVersion: minimumVersion,
        message: '',
        storeUrl: storeUrl,
      );
    } catch (e) {
      print('Error checking for update: $e');
      // Return no update on error
      return UpdateInfo(
        status: UpdateStatus.noUpdateRequired,
        currentVersion: '1.0.0',
        minimumVersion: '1.0.0',
        message: '',
        storeUrl: '',
      );
    }
  }

  /// Compare two version strings (e.g., "1.2.3" vs "1.3.0")
  /// Returns true if current version is lower than required version
  bool _isVersionLower(String currentVersion, String requiredVersion) {
    try {
      final current = currentVersion.split('.').map(int.parse).toList();
      final required = requiredVersion.split('.').map(int.parse).toList();

      // Pad with zeros if needed
      while (current.length < required.length) {
        current.add(0);
      }
      while (required.length < current.length) {
        required.add(0);
      }

      // Compare each part
      for (int i = 0; i < current.length; i++) {
        if (current[i] < required[i]) return true;
        if (current[i] > required[i]) return false;
      }

      return false; // Versions are equal
    } catch (e) {
      print('Error comparing versions: $e');
      return false;
    }
  }

  Future<void> openStore(String storeUrl) async {
    try {
      final uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print('Error opening store: $e');
    }
  }
}

