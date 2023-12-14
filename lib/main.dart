import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:must_fam_songs/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:must_fam_songs/screens/home_page.dart';
import 'package:must_fam_songs/model/boxes.dart';
import 'package:must_fam_songs/model/favorite_songs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Logger.level = Level.info;

  final prefs = await SharedPreferences.getInstance();
  final firstTime = prefs.getBool('firstTime') ?? true;

  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteSongsAdapter());
  boxFavoriteSongs = await Hive.openBox<FavoriteSongs>("favoriteSongsBox");
  await Hive.openBox("settings");

  if (firstTime) {
    runApp(const MyApp(showWelcomePage: true));
    await prefs.setBool('firstTime', false);
  } else {
    runApp(const MyApp(showWelcomePage: false));
  }
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
                      fontFamily: 'Ubuntu',
                      colorSchemeSeed: Colors.green[700],
                    )
                  : ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                          seedColor: const Color.fromARGB(255, 56, 142, 60)),
                      brightness: Brightness.light,
                      useMaterial3: true,
                      fontFamily: 'Ubuntu',
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
                      fontFamily: 'Ubuntu',
                      colorSchemeSeed: Colors.green[700],
                    )
                  : ThemeData(
                      colorSchemeSeed: Colors.green[700],
                      brightness: Brightness.light,
                      useMaterial3: true,
                      fontFamily: 'Ubuntu',
                    ),
              home: const HomePage(),
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
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          backgroundColor: Colors.green[700],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/music_note.png',
                  width: 110.w,
                  height: 210.h,
                ),
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  'MUST FAM',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontFamily: 'Ubuntu',
                  ),
                ),
                Text(
                  'SONGS',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontFamily: 'Ubuntu',
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: Size(
                      200.w,
                      50.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Ubuntu",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
