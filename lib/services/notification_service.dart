import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  Future<void> initNotifications() async {
    // Pede permissão ao usuário (Crítico para Android 13+ e iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('Permissão de notificação concedida!');
      }

      final fcmToken = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('Token do Dispositivo: $fcmToken');
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Recebi uma notificação enquanto o app estava aberto:');
          print('Título: ${message.notification?.title}');
          print('Corpo: ${message.notification?.body}');
        }
      });
    } else {
      if (kDebugMode) {
        print('Permissão de notificação negada.');
      }
    }
  }
}
