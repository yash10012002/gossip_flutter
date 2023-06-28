import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:gossip_flutter/api/apis.dart';
import 'package:gossip_flutter/screens/auth/login_screen.dart';
import 'package:gossip_flutter/screens/globle.dart';
import 'package:gossip_flutter/screens/home_screen.dart';
import 'firebase_options.dart';

late Size mq;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent));
  _initializeFirebase();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (APIs.auth.currentUser != null) {
      log("\nUser: ${FirebaseAuth.instance.currentUser}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gossip',
      theme: ThemeData(
          primaryColor: Colors.blue,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0.5,
            iconTheme: IconThemeData(
              color: Color.fromARGB(255, 14, 112, 193),
            ),
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(
                color: Color.fromARGB(255, 14, 112, 193),
                fontWeight: FontWeight.bold,
                fontSize: 20),
          )),
      home: APIs.auth.currentUser != null ? HomeScreen() : LoginScreen(),
      navigatorKey: GlobalVariable.navigatorKey,
    );
  }
}

_initializeFirebase() async {
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  log('\nNotification Chanel Result: $result');
}
