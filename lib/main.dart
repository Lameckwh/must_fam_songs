import 'package:flutter/material.dart';
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
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MUST FAM SONGS',
            theme: isDark
                ? ThemeData(
                    brightness: Brightness.dark,
                    useMaterial3: true,
                    fontFamily: 'Ubuntu',
                  )
                : ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
                    brightness: Brightness.light,
                    useMaterial3: true,
                    fontFamily: 'Ubuntu',
                  ),
            home: const WelcomePage(title: 'MUST FAM SONGS'),
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
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/music_note.png', width: 150, // Set the width of the image
              height: 250,
            ),
            // Make sure to place your image in the 'assets' folder
            const SizedBox(height: 70),
            const Text(
              'MUST FAM',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontFamily: 'Ubuntu'),
            ),
            const Text(
              'SONGS',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontFamily: 'Ubuntu'),
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(200, 50), // Set button width and height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Set border radius
                ),
                // Set the background color to orange
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Ubuntu"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
