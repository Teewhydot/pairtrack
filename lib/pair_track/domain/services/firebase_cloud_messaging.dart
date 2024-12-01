import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage? message) async {
  if (message != null) {
  }
}

class FireBaseMessagingApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
      announcement: true,
    );
    await _firebaseMessaging.getToken();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((message){
final notification =  message.notification;
      if(notification != null){
      }
    });
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
      }
    });
  }

  Future<String?> getFcmToken() async {
    String? FCMtoken = await _firebaseMessaging.getToken();
    _firebaseMessaging.onTokenRefresh.listen((token) {
      FCMtoken = token;
    });
    return FCMtoken;
  }
}
