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
import '../../features/news/presentation/pages/article_details_page.dart';
import '../../features/news/data/repositories/news_repository_impl.dart';
import '../../features/news/domain/entities/article.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(fcm.RemoteMessage message) async {
  dev.log("Handling a background message: ${message.messageId}");
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString('notifications_history');
  List history = [];
  if (data != null) {
    try { history = jsonDecode(data); } catch (_) {}
  }
  
  if (message.notification != null) {
    final title = message.notification!.title ?? '';
    final body = message.notification!.body ?? '';
    
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
        'tweetId': message.data['tweetId'],
        'collection': message.data['collection'],
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
  Map<String, dynamic>? _pendingDeepLink;

  Future<void> init() async {
    if (_isInitialized) return;
    
    dev.log("🚀 Initializing NotificationService...");
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      dev.log("Timezone error: $e");
    }
    
    // 1. Setup Local Notifications
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
        dev.log("Notification clicked (Local): ${details.payload}");
        if (details.payload != null) {
          try {
            final data = jsonDecode(details.payload!);
            handleDeepLink(data);
          } catch (e) {
            _navigateToNotifications();
          }
        } else {
          _navigateToNotifications();
        }
      },
    );

    // 2. Create Channels
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    // 3. Initialize Firebase Messaging
    await _initFirebaseMessaging();

    // 4. Handle terminated state launch (Cold Start)
    // We do this AFTER a small delay to ensure navigator key is ready
    Future.delayed(const Duration(seconds: 1), () async {
      fcm.RemoteMessage? initialMessage = await fcm.FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        dev.log("🔥 App opened from terminated state via FCM: ${initialMessage.messageId}");
        handleDeepLink(initialMessage.data);
      } else {
        // Also check Local Notifications launch details for cold start
        final details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
        if (details?.didNotificationLaunchApp ?? false) {
           final payload = details?.notificationResponse?.payload;
           if (payload != null) {
             handleDeepLink(jsonDecode(payload));
           }
        }
      }
    });

    final prefs = await SharedPreferences.getInstance();
    final bool enabled = prefs.getBool('breakingNews') ?? true;
    
    if (enabled) {
      final bool granted = await _requestPermissions();
      if (granted) {
        await subscribeToTopics();
        await _sendWelcomeNotificationIfNeeded(prefs);
      }
    }
    
    _isInitialized = true;
    dev.log("✅ NotificationService initialized successfully");
  }

  void _navigateToNotifications() {
    if (NotificationsScreen.isVisible) return;
    
    _safeNavigate((context) => const NotificationsScreen());
  }

  Future<void> handleDeepLink(Map<String, dynamic> data) async {
    final tweetId = data['tweetId'];
    if (tweetId == null) {
      _navigateToNotifications();
      return;
    }

    dev.log("🔗 Handling Deep Link for tweetId: $tweetId");
    final String? collection = data['collection'];
    final repository = NewsRepositoryImpl();

    Article? article;
    try {
      if (collection != null && collection.isNotEmpty) {
        article = await repository.getArticleById(tweetId, collection: collection);
      }
      
      // If not found in primary collection, try fallbacks
      if (article == null) {
        final collections = ['news', 'technology', 'spl', 'jobs'];
        for (var coll in collections) {
          if (coll == collection) continue;
          article = await repository.getArticleById(tweetId, collection: coll);
          if (article != null) break;
        }
      }
    } catch (e) {
      dev.log("⚠️ Deep link fetch error: $e");
    }

    if (article != null) {
      _safeNavigate((context) => ArticleDetailsPage(article: article!));
    } else {
      dev.log("❌ Article not found for deep link, falling back to notifications list");
      _navigateToNotifications();
    }
  }

  /// Ensures navigation happens only when the navigator is ready
  void _safeNavigate(WidgetBuilder builder) {
    if (navigatorKey.currentState == null) {
      dev.log("⌛ Navigator not ready, retrying navigation in 1s...");
      Future.delayed(const Duration(seconds: 1), () => _safeNavigate(builder));
      return;
    }

    navigatorKey.currentState!.push(
      MaterialPageRoute(builder: builder),
    );
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'fcm_foreground_channel',
      'إشعارات عامة',
      description: 'إشعارات مستلمة أثناء استخدام التطبيق',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
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

  Future<void> subscribeToTopics() async {
    final fcm.FirebaseMessaging messaging = fcm.FirebaseMessaging.instance;
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
        dev.log('🔔 Successfully subscribed to $topic');
      } catch (e) {
        dev.log('⚠️ Failed to subscribe to $topic: $e');
      }
    }
  }

  Future<void> saveToHistory(String title, String body, {String? tweetId, String? collection}) async {
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
      'tweetId': tweetId,
      'collection': collection,
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

    fcm.FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initial permissions check
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus == fcm.AuthorizationStatus.authorized) {
      await subscribeToTopics();
      String? token = await messaging.getToken();
      dev.log('FCM Token: $token');
    }

    // Handle background-to-foreground launch (App was in background, not terminated)
    fcm.FirebaseMessaging.onMessageOpenedApp.listen((fcm.RemoteMessage message) {
      dev.log("🔔 FCM message opened app (Background): ${message.messageId}");
      handleDeepLink(message.data);
    });

    // Handle foreground messages
    fcm.FirebaseMessaging.onMessage.listen((fcm.RemoteMessage message) {
      dev.log('🔔 FCM message received in foreground: ${message.messageId}');
      _handleFcmMessage(message);

      if (message.notification != null) {
        _showForegroundNotification(message.notification!, message.data);
      }
    });
  }

  void _handleFcmMessage(fcm.RemoteMessage message) {
    if (message.notification != null) {
      saveToHistory(
        message.notification!.title ?? '', 
        message.notification!.body ?? '',
        tweetId: message.data['tweetId'],
        collection: message.data['collection'],
      );
    }
  }

  Future<void> _showForegroundNotification(fcm.RemoteNotification notification, Map<String, dynamic> data) async {
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
      payload: jsonEncode(data),
    );
  }
}
