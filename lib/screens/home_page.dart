import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:must_fam_songs/screens/about_page.dart';
import 'package:must_fam_songs/fam_events/events_page.dart';
import 'package:must_fam_songs/screens/favorite_songs_page.dart';
import 'package:must_fam_songs/screens/song_list_page.dart';
// import 'package:must_fam_songs/song_lyrics_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static final List<Widget> _pages = <Widget>[
    const SongListPage(),
    const FavoritesPage(),
    const EventsPage(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, box, child) {
        final isDark = box.get("isDark", defaultValue: false);

        return Scaffold(
          body: _pages.elementAt(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note),
                label: 'Songs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info),
                label: 'About',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.green[700],
            onTap: _onItemTapped,
            unselectedItemColor: isDark
                ? Colors.white54
                : Colors.black54, // Adjust the color here
            showUnselectedLabels: true,
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
