import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'data/services/firestore_service.dart';
import 'data/services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/team_provider.dart';
import 'providers/theme_provider.dart';

/// Runs in a background isolate when a push arrives and the app is
/// terminated/background. The system shows the notification payload itself.
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
  await NotificationService.instance.init();
  // Seed default teams (A/B/C) if they don't exist yet — best effort.
  FirestoreService.instance.ensureTeams();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
      ],
      child: const VeeraVidhaiApp(),
    ),
  );
}
