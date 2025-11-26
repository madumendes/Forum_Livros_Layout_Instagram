import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // 1. INICIALIZAR O SERVIÇO
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

      // 2. OBTER O TOKEN (Identidade do celular)
      // Você usaria esse token para enviar msg específica para este usuário
      final fcmToken = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('Token do Dispositivo: $fcmToken');
      }

      // 3. OUVIR NOTIFICAÇÕES COM O APP ABERTO (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Recebi uma notificação enquanto o app estava aberto:');
          print('Título: ${message.notification?.title}');
          print('Corpo: ${message.notification?.body}');
        }
        // Aqui você poderia mostrar um "SnackBar" ou um diálogo
      });
    } else {
      if (kDebugMode) {
        print('Permissão de notificação negada.');
      }
    }
  }
}
