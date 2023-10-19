import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:must_fam_songs/home_page.dart';
import 'package:must_fam_songs/model/boxes.dart';
import 'package:must_fam_songs/model/favorite_songs.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteSongsAdapter());
  boxFavoriteSongs = await Hive.openBox<FavoriteSongs>("favoriteSongsBox");
  await Hive.openBox("settings");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box('settings').listenable(),
        builder: (context, box, child) {
          final isDark = box.get("isDark", defaultValue: false);
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
                      colorScheme:
                          ColorScheme.fromSeed(seedColor: Colors.orange),
                      brightness: Brightness.light,
                      useMaterial3: true,
                      fontFamily: 'Ubuntu',
                      // colorSchemeSeed: Colors.green[700],
                    ),
              home: const WelcomePage(title: 'MUST FAM SONGS'),
            ),
          );
        });
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
                  width: 110.w, // Using ScreenUtil for responsive width
                  height: 210.h, // Using ScreenUtil for responsive height
                ),
                SizedBox(
                    height: 30.h), // Using ScreenUtil for responsive height
                Text(
                  'MUST FAM',
                  style: TextStyle(
                      fontSize:
                          32.sp, // Using ScreenUtil for responsive font size
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontFamily: 'Ubuntu'),
                ),
                Text(
                  'SONGS',
                  style: TextStyle(
                      fontSize:
                          32.sp, // Using ScreenUtil for responsive font size
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontFamily: 'Ubuntu'),
                ),
                SizedBox(
                    height: 35.h), // Using ScreenUtil for responsive height
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
                        200.w, 50.h), // Using ScreenUtil for responsive size
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5), // Set border radius
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            20.sp, // Using ScreenUtil for responsive font size
                        fontWeight: FontWeight.bold,
                        fontFamily: "Ubuntu"),
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
