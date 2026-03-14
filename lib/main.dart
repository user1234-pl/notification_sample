import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// ✅ Register background handler
  FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotificationPage(),
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() =>
      _NotificationPageState();
}

class _NotificationPageState
    extends State<NotificationPage> {

  final List<Map<String, String>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _setupFirebase();
  }

  Future<void> _setupFirebase() async {

    /// ✅ Request Permission
    NotificationSettings settings =
    await FirebaseMessaging.instance
        .requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print(
        "Permission: ${settings.authorizationStatus}");

    /// ✅ Foreground Message
    FirebaseMessaging.onMessage
        .listen((RemoteMessage message) {
      setState(() {
        _notifications.insert(0, {
          "title":
          message.notification?.title ??
              "No Title",
          "body":
          message.notification?.body ??
              "No Body",
          "time": DateTime.now()
              .toLocal()
              .toString()
              .split('.')[0],
        });
      });
    });

    /// ✅ Notification Click
    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
              "Clicked: ${message.notification?.title}"),
        ),
      );
    });

    /// ✅ Print FCM Token
    String? token =
    await FirebaseMessaging.instance
        .getToken();
    print("FCM Token: $token");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Firebase Push Notifications"),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
            const Icon(Icons.delete_forever),
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
            },
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
        child: Text(
          "No notifications yet",
          style: TextStyle(
              fontSize: 18,
              color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding:
        const EdgeInsets.all(8),
        itemCount:
        _notifications.length,
        itemBuilder:
            (context, index) {
          final notification =
          _notifications[index];

          return Card(
            margin:
            const EdgeInsets
                .symmetric(
                vertical: 6),
            child: ListTile(
              leading: const Icon(
                  Icons.notifications,
                  color:
                  Colors.indigo),
              title: Text(
                notification[
                "title"]!,
                style: const TextStyle(
                    fontWeight:
                    FontWeight
                        .bold),
              ),
              subtitle: Text(
                  notification[
                  "body"]!),
              trailing: Text(
                notification[
                "time"]!,
                style:
                const TextStyle(
                    fontSize:
                    12),
              ),
            ),
          );
        },
      ),
    );
  }
}