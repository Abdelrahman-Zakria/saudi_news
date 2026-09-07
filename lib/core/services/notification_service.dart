import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../features/settings/presentation/pages/notifications_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(fcm.RemoteMessage message) async {
  // Ensure background isolate can use SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString('notifications_history');
  List history = [];
  if (data != null) {
    try { history = jsonDecode(data); } catch (_) {}
  }
  
  if (message.notification != null) {
    final title = message.notification!.title ?? '';
    final body = message.notification!.body ?? '';
    
    // Simple duplicate check
    final bool alreadyExists = history.any((e) => 
      e['title'] == title && 
      e['body'] == body
    );
    
    if (!alreadyExists) {
      history.insert(0, {
        'title': title,
        'body': body,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });
      if (history.length > 50) history.removeLast();
      await prefs.setString('notifications_history', jsonEncode(history));
    }
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    
    // FCM Initialization
    await _initFirebaseMessaging();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
        
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        dev.log("Notification clicked: ${details.payload}");
        _navigateToNotifications();
      },
    );

    // Create Notification Channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    // Check if app was opened from a notification when terminated
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      _navigateToNotifications();
    }

    final prefs = await SharedPreferences.getInstance();
    final bool enabled = prefs.getBool('breakingNews') ?? true;
    
    if (enabled) {
      final bool granted = await _requestPermissions();
      if (granted) {
        // Send welcome notification if first time
        await _sendWelcomeNotificationIfNeeded(prefs);
      }
    }
    
    _isInitialized = true;
  }

  void _navigateToNotifications() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
      }
    });
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'fcm_foreground_channel',
      'إشعارات عامة',
      description: 'إشعارات مستلمة أثناء استخدام التطبيق',
      importance: Importance.max,
      playSound: true,
    );

    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
      
      final bool? granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    } catch (e) {
      dev.log("Error requesting permissions: $e");
      return false;
    }
  }

  Future<void> saveToHistory(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('notifications_history');
    List history = [];
    if (data != null) {
      try { history = jsonDecode(data); } catch (_) {}
    }
    
    final bool alreadyExists = history.any((e) => 
      e['title'] == title && 
      e['body'] == body
    );
    
    if (alreadyExists) return;

    history.insert(0, {
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    });
    
    if (history.length > 50) history.removeLast();
    await prefs.setString('notifications_history', jsonEncode(history));
  }

  Future<void> _sendWelcomeNotificationIfNeeded(SharedPreferences prefs) async {
    final bool isFirstTime = prefs.getBool('first_time_welcome_sent') ?? true;

    if (isFirstTime) {
      const String title = 'مرحباً بك في أخبار السعودية 🇸🇦';
      const String body = 'نتمنى لك تجربة ممتعة ومتابعة شيقة لآخر الأخبار والمستجدات!';
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'fcm_foreground_channel',
        'إشعارات عامة',
        channelDescription: 'إشعارات مستلمة أثناء استخدام التطبيق',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
      );
      
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      try {
        await flutterLocalNotificationsPlugin.show(
          999, // Unique ID for welcome
          title,
          body,
          platformChannelSpecifics,
        );
        await saveToHistory(title, body);
        await prefs.setBool('first_time_welcome_sent', false);
      } catch (e) {
        dev.log("Error showing welcome notification: $e");
      }
    }
  }

  // --- Firebase Cloud Messaging ---

  Future<void> _initFirebaseMessaging() async {
    fcm.FirebaseMessaging messaging = fcm.FirebaseMessaging.instance;

    // Set background handler
    fcm.FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    fcm.NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == fcm.AuthorizationStatus.authorized) {
      dev.log('User granted FCM permission');
      
      String? token = await messaging.getToken();
      dev.log('FCM Token: $token');
      
      // Auto-subscribe to necessary topics from Railway script
      final List<String> topics = [
        'all_users',
        'news_topic',
        'jobs_topic',
        'spl_topic',
        'technology_topic'
      ];
      
      for (var topic in topics) {
        try {
          await messaging.subscribeToTopic(topic);
          dev.log('Subscribed to $topic topic');
        } catch (e) {
          dev.log('Error subscribing to $topic topic: $e');
        }
      }
    }

    fcm.RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleFcmMessage(initialMessage);
      _navigateToNotifications();
    }

    fcm.FirebaseMessaging.onMessageOpenedApp.listen((fcm.RemoteMessage message) {
      _handleFcmMessage(message);
      _navigateToNotifications();
    });

    fcm.FirebaseMessaging.onMessage.listen((fcm.RemoteMessage message) {
      dev.log('Got a message whilst in the foreground!');
      _handleFcmMessage(message);

      if (message.notification != null) {
        _showForegroundNotification(message.notification!);
      }
    });
  }

  void _handleFcmMessage(fcm.RemoteMessage message) {
    if (message.notification != null) {
      saveToHistory(
        message.notification!.title ?? '', 
        message.notification!.body ?? '',
      );
    }
  }

  Future<void> _showForegroundNotification(fcm.RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'fcm_foreground_channel',
      'إشعارات عامة',
      channelDescription: 'إشعارات مستلمة أثناء استخدام التطبيق',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    
    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }
}
