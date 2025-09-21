import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userflow/core/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  return await notificationService.getFCMToken();
});

final notificationPermissionProvider = FutureProvider<bool>((ref) async {
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.getNotificationSettings();
  return settings.authorizationStatus == AuthorizationStatus.authorized;
});

final showNotificationProvider = Provider<void Function(String, String)>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  return (String title, String body) {
    notificationService.showNotification(title: title, body: body);
  };
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

final notificationEnabledProvider = StateNotifierProvider<NotificationEnabledNotifier, bool>((ref) {
  return NotificationEnabledNotifier(ref.read(sharedPreferencesProvider));
});

final toggleNotificationProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(notificationEnabledProvider.notifier).toggle();
  };
});
class NotificationEnabledNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const String _key = 'notification_enabled';

  NotificationEnabledNotifier(this._prefs) : super(_prefs.getBool(_key) ?? true);

  Future<void> toggle() async {
    final newValue = !state;
    state = newValue;
    await _prefs.setBool(_key, newValue);
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _prefs.setBool(_key, enabled);
  }
}
