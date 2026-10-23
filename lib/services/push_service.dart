import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/config/app_config.dart';
import '../data/repositories/support_repository.dart';

enum PushStatus { unsupported, notAsked, granted, denied }

/// Push notifications through Firebase Cloud Messaging — the same backend that notifies the website.
/// Order updates (confirmed, shipped, delivered) and offers arrive on every linked device.
class PushService {
  PushService._();
  static final instance = PushService._();

  final _local = FlutterLocalNotificationsPlugin();
  final _support = SupportRepository();
  bool _ready = false;

  /// Called with the notification's link (a website URL or app path) when it is tapped.
  void Function(String link)? onOpen;

  static String get _appId => Platform.isIOS ? AppConfig.firebaseIosAppId : AppConfig.firebaseAndroidAppId;

  /// True once the Firebase Android/iOS app ID is set in AppConfig.
  bool get configured => _appId.isNotEmpty;

  Future<void> init() async {
    if (!configured || _ready) return;
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: AppConfig.firebaseApiKey,
          appId: _appId,
          messagingSenderId: AppConfig.firebaseSenderId,
          projectId: AppConfig.firebaseProjectId,
        ),
      );
      await _local.initialize(
        const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings()),
        onDidReceiveNotificationResponse: (r) => r.payload != null ? onOpen?.call(r.payload!) : null,
      );
      await _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
        const AndroidNotificationChannel('orders', 'Orders & offers', importance: Importance.high),
      );

      // App open → show the notification ourselves (FCM only shows it automatically in the background)
      FirebaseMessaging.onMessage.listen((m) {
        final n = m.notification;
        if (n == null) return;
        _local.show(
          m.hashCode,
          n.title,
          n.body,
          const NotificationDetails(
            android: AndroidNotificationDetails('orders', 'Orders & offers', importance: Importance.high, priority: Priority.high),
          ),
          payload: m.data['link'] as String?,
        );
      });
      FirebaseMessaging.onMessageOpenedApp.listen((m) => _open(m));
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) Future.delayed(const Duration(milliseconds: 800), () => _open(initial));
      _ready = true;
    } catch (e) {
      debugPrint('[push] init failed: $e');
    }
  }

  void _open(RemoteMessage m) {
    final link = m.data['link'] as String? ?? m.notification?.android?.clickAction;
    if (link != null) onOpen?.call(link);
  }

  Future<PushStatus> status() async {
    if (!_ready) return PushStatus.unsupported;
    final s = await FirebaseMessaging.instance.getNotificationSettings();
    return switch (s.authorizationStatus) {
      AuthorizationStatus.authorized || AuthorizationStatus.provisional => PushStatus.granted,
      AuthorizationStatus.denied => PushStatus.denied,
      _ => PushStatus.notAsked,
    };
  }

  /// Asks for permission and links this device to the logged-in account. Returns the new status.
  Future<PushStatus> enable({required bool loggedIn}) async {
    if (!_ready) return PushStatus.unsupported;
    final s = await FirebaseMessaging.instance.requestPermission();
    if (s.authorizationStatus == AuthorizationStatus.denied) return PushStatus.denied;
    if (loggedIn) await linkDevice();
    return PushStatus.granted;
  }

  /// POST /notifications/devices with this phone's FCM token (after login, and on every app start).
  Future<void> linkDevice() async {
    if (!_ready || await status() != PushStatus.granted) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _support.addDevice(token, '${Platform.operatingSystem} app');
    } catch (e) {
      debugPrint('[push] link failed: $e');
    }
  }

  /// DELETE /notifications/devices — call before logging out.
  Future<void> unlinkDevice() async {
    if (!_ready) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _support.removeDevice(token);
    } catch (_) {}
  }
}
