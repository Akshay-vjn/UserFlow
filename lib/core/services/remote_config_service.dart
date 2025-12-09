import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

class RemoteConfigService {
  FirebaseRemoteConfig? _remoteConfig;

  Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      // Use zero interval for immediate updates in both debug and production
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,  // Immediate fetch always
        ),
      );

      // Set default values
      await _remoteConfig!.setDefaults({
        'force_update_required': false,
        'minimum_version_android': '1.0.0',
        'minimum_version_ios': '1.0.0',
        'update_message': 'Your app version is outdated. Please update to continue using the app.',
        'android_store_url': 'https://play.google.com/store/apps/details?id=com.yourapp.id',
        'ios_store_url': 'https://apps.apple.com/app/id123456789',
      });

      // Fetch and activate
      final fetchResult = await _remoteConfig!.fetchAndActivate();
      
      if (kDebugMode) {
        print('=== Remote Config Debug Info ===');
        print('Fetch result: $fetchResult');
        print('Last fetch time: ${_remoteConfig!.lastFetchTime}');
        print('Last fetch status: ${_remoteConfig!.lastFetchStatus}');
        print('Remote Config initialized - immediate fetch enabled (no cache)');
        print('force_update_required: ${getForceUpdateRequired()}');
        print('minimum_version_android: ${getMinimumVersionAndroid()}');
        print('minimum_version_ios: ${getMinimumVersionIos()}');
        print('Raw Firebase values:');
        print('  force_update_required: ${_remoteConfig!.getValue('force_update_required').asBool()}');
        print('  minimum_version_android: ${_remoteConfig!.getValue('minimum_version_android').asString()}');
        print('  minimum_version_ios: ${_remoteConfig!.getValue('minimum_version_ios').asString()}');
        print('================================');
      }
    } catch (e) {
      print('Error initializing Remote Config: $e');
    }
  }

  bool getForceUpdateRequired() {
    return _remoteConfig?.getBool('force_update_required') ?? false;
  }

  String getMinimumVersionAndroid() {
    return _remoteConfig?.getString('minimum_version_android') ?? '1.0.0';
  }

  String getMinimumVersionIos() {
    return _remoteConfig?.getString('minimum_version_ios') ?? '1.0.0';
  }

  String getMinimumVersion() {
    // This method is kept for backward compatibility
    // It returns the appropriate platform-specific version
    if (Platform.isAndroid) {
      return getMinimumVersionAndroid();
    } else if (Platform.isIOS) {
      return getMinimumVersionIos();
    } else {
      // Default to Android version for other platforms
      return getMinimumVersionAndroid();
    }
  }

  String getUpdateMessage() {
    return _remoteConfig?.getString('update_message') ?? 
        'Your app version is outdated. Please update to continue using the app.';
  }

  String getAndroidStoreUrl() {
    return _remoteConfig?.getString('android_store_url') ?? 
        'https://play.google.com/store/apps/details?id=com.yourapp.id';
  }

  String getIosStoreUrl() {
    return _remoteConfig?.getString('ios_store_url') ?? 
        'https://apps.apple.com/app/id123456789';
  }

  Future<void> refresh() async {
    try {
      if (kDebugMode) {
        print('Fetching latest Remote Config values...');
      }
      
      final updated = await _remoteConfig?.fetchAndActivate();
      
      if (kDebugMode) {
        print('Remote Config refresh ${updated == true ? "successful" : "no changes"}');
        print('force_update_required: ${getForceUpdateRequired()}');
        print('minimum_version_android: ${getMinimumVersionAndroid()}');
        print('minimum_version_ios: ${getMinimumVersionIos()}');
        print('current_platform: ${Platform.isAndroid ? "Android" : Platform.isIOS ? "iOS" : "Other"}');
      }
    } catch (e) {
      print('Error refreshing Remote Config: $e');
    }
  }
}

