import 'package:animated_icon/animated_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:must_fam_songs/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:must_fam_songs/screens/home_page.dart';
import 'package:must_fam_songs/models/boxes.dart';
import 'package:must_fam_songs/models/favorite_songs.dart';
import 'package:must_fam_songs/fam_events/events/event_details.dart';
import 'package:must_fam_songs/fam_events/announcements/announcement_detail.dart';
import 'models/Announcement.dart';
import 'models/Event.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize flutter_local_notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      final String? payload = notificationResponse.payload;
      if (payload != null) {
        // Handle notification response here

        // Parse the payload and navigate accordingly
        final data = payload.split(':');
        final type = data[0]; // Event or Announcement
        final id = data[1]; // Identifier

        if (type == 'event') {
          // Fetch event details from Firestore or your data source
          final event = await fetchEventDetails(id);
          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => EventDetails(
                title: event.title,
                description: event.description,
                dateOfEvent: event.dateOfEvent,
                imageUrl: event.imageUrl,
              ),
            ),
          );
        } else if (type == 'announcement') {
          // Fetch announcement details from Firestore or your data source
          final announcement = await fetchAnnouncementDetails(id);
          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetail(
                title: announcement.title,
                description: announcement.description,
                datePosted: announcement.datePosted,
                imageUrl: announcement.imageUrl,
              ),
            ),
          );
        }
      }
    },
  );

  // Initialize Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Logger.level = Level.info;

  final prefs = await SharedPreferences.getInstance();
  final lastSeenEventTime = prefs.getString('lastSeenEventTime');
  final lastSeenAnnouncementTime = prefs.getString('lastSeenAnnouncementTime');

  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteSongsAdapter());
  boxFavoriteSongs = await Hive.openBox<FavoriteSongs>("favoriteSongsBox");
  await Hive.openBox("settings");

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Subscribe to 'events' topic
  messaging.subscribeToTopic('events');

  // Subscribe to 'announcements' topic
  messaging.subscribeToTopic('announcements');

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  } else {
    Logger().w('User declined or has not accepted permission');
  }

  // Get the FCM token for this device
  String? token = await messaging.getToken();
  Logger().i('FCM Token: $token');

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    Logger().i('Received a message in the foreground: ${message.messageId}');
    if (message.notification != null) {
      Logger()
          .i('Message also contained a notification: ${message.notification}');
      _showNotification(message);
    }
  });

  // Listen for Firestore changes and show notifications
  FirebaseFirestore.instance
      .collection('events')
      .where('timestamp', isGreaterThan: lastSeenEventTime ?? "")
      .snapshots()
      .listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        final event = Event.fromFirestore(change.doc);
        _showNotificationFromFirestore('Event', event.id, event.title);
        // Update last seen timestamp
        prefs.setString('lastSeenEventTime', event.timestamp.toString());
      }
    }
  });

  FirebaseFirestore.instance
      .collection('announcements')
      .where('timestamp', isGreaterThan: lastSeenAnnouncementTime ?? "")
      .snapshots()
      .listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        final announcement = Announcement.fromFirestore(change.doc);
        _showNotificationFromFirestore(
            'Announcement', announcement.id, announcement.title);
        // Update last seen timestamp
        prefs.setString(
            'lastSeenAnnouncementTime', announcement.timestamp.toString());
      }
    }
  });

  final firstTime = prefs.getBool('firstTime') ?? true;
  if (firstTime) {
    runApp(const MyApp(showWelcomePage: true));
    await prefs.setBool('firstTime', false);
  } else {
    runApp(const MyApp(showWelcomePage: false));
  }
}

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'default_channel_id',
    'Default Channel',
    channelDescription: 'Default channel for notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
    payload: '${message.data['type']}:${message.data['id']}',
  );
}

Future<void> _showNotificationFromFirestore(
    String type, String id, String title) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'default_channel_id',
    'Default Channel',
    channelDescription: 'Default channel for notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    icon: '@mipmap/ic_launcher',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'New $type Posted!',
    '$title ...',
    platformChannelSpecifics,
    payload: '$type:$id',
  );
}

Future<Event> fetchEventDetails(String id) async {
  final doc =
      await FirebaseFirestore.instance.collection('events').doc(id).get();
  return Event.fromFirestore(doc);
}

Future<Announcement> fetchAnnouncementDetails(String id) async {
  final doc = await FirebaseFirestore.instance
      .collection('announcements')
      .doc(id)
      .get();
  return Announcement.fromFirestore(doc);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.showWelcomePage});

  final bool showWelcomePage;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, box, child) {
        final isDark = box.get("isDark", defaultValue: false);
        if (showWelcomePage) {
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'MUST FAM SONGS',
              theme: isDark
                  ? ThemeData(
                      brightness: Brightness.dark,
                      useMaterial3: true,
                      fontFamily: 'ProximaSoft',
                      colorSchemeSeed: Colors.green[700],
                    )
                  : ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                          seedColor: const Color.fromARGB(255, 56, 142, 60)),
                      brightness: Brightness.light,
                      useMaterial3: true,
                      fontFamily: 'ProximaSoft',
                    ),
              home: const WelcomePage(title: 'MUST FAM SONGS'),
            ),
          );
        } else {
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'MUST FAM SONGS',
              theme: isDark
                  ? ThemeData(
                      brightness: Brightness.dark,
                      useMaterial3: true,
                      fontFamily: 'ProximaSoft',
                      colorSchemeSeed: Colors.green[700],
                    )
                  : ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                          seedColor: const Color.fromARGB(255, 56, 142, 60)),
                      brightness: Brightness.light,
                      useMaterial3: true,
                      fontFamily: 'ProximaSoft',
                    ),
              home: const HomePage(),
              navigatorKey: navigatorKey,
            ),
          );
        }
      },
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, required this.title});

  final String title;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double _curtainHeight = 0.0;
  bool _isSwiping = false;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _curtainHeight -= details.primaryDelta!;
      if (_curtainHeight < 0) _curtainHeight = 0;
      if (_curtainHeight > MediaQuery.of(context).size.height) {
        _curtainHeight = MediaQuery.of(context).size.height;
      }
      _isSwiping = true; // Indicate that the user is swiping
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _isSwiping = false; // Reset swipe state when the drag ends
    });

    if (_curtainHeight > MediaQuery.of(context).size.height / 2) {
      setState(() {
        _curtainHeight = MediaQuery.of(context).size.height;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      });
    } else {
      setState(() {
        _curtainHeight = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          backgroundColor: Colors.green[700],
          body: Stack(
            children: [
              const HomePage(), // The page revealed when the curtain is pulled up
              GestureDetector(
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: MediaQuery.of(context).size.height - _curtainHeight,
                  color: Colors.green[700],
                  child: Stack(
                    children: [
                      // Curtain content aligned at the top
                      Positioned(
                        top: -100,
                        left: 0,
                        right: 0,
                        bottom:
                            0, // This makes the Column take up the entire space available
                        child: Column(
                          mainAxisSize: MainAxisSize
                              .min, // Ensures the Column only takes as much vertical space as needed
                          children: [
                            Expanded(
                              child: Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'images/music_note.png',
                                        width: 110.0,
                                        height: 210.0,
                                      ),
                                      const SizedBox(height: 30),
                                      const Text(
                                        'MUST FAM',
                                        style: TextStyle(
                                          fontSize: 32.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                          fontFamily: 'ProximaSoft',
                                        ),
                                      ),
                                      const Text(
                                        'SONGS',
                                        style: TextStyle(
                                          fontSize: 32.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                          fontFamily: 'ProximaSoft',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Swipe up indicator at the bottom
                      if (!_isSwiping) // Show only if not swiping
                        Positioned(
                          bottom: 30,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Transform.rotate(
                                angle:
                                    3.14159, // This is PI, which rotates the icon 180 degrees.
                                child: AnimateIcon(
                                  key: UniqueKey(),
                                  onTap: () {},
                                  iconType: IconType.continueAnimation,
                                  height: 70,
                                  width: 70,
                                  color: Colors.orange,
                                  animateIcon: AnimateIcons.downArrow,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Swipe Up to Get Started',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
