import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:userflow/app.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _requestPermission();
    
    await _initializeLocalNotifications();
    
    await _getFCMToken();
    
    _setupMessageHandlers();
  }

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'userflow_channel',
      'UserFlow Notifications',
      description: 'Notifications for UserFlow app',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<String?> _getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    _handleTerminatedMessage();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');
    
    await _showLocalNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? 'You have a new message',
      payload: message.data.toString(),
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('Received background message: ${message.messageId}');
    _navigateToScreen(message.data);
  }

  Future<void> _handleTerminatedMessage() async {
    final RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated state: ${initialMessage.messageId}');
      _navigateToScreen(initialMessage.data);
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'userflow_channel',
      'UserFlow Notifications',
      channelDescription: 'Notifications for UserFlow app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    if (response.payload != null) {
      _navigateToScreen({});
    }
  }

  void _navigateToScreen(Map<String, dynamic> data) {
    rootNavigatorKey.currentState?.pushNamed('/home');
  }

  Future<String?> getFCMToken() async {
    return await _getFCMToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}