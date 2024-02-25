import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:must_fam_songs/screens/favorite_songs_page.dart';
import 'package:must_fam_songs/model/boxes.dart';
import 'package:must_fam_songs/model/favorite_songs.dart';
import 'package:must_fam_songs/song.dart';

class LyricsPage extends StatefulWidget {
  final List<Song> songs;
  final Song song;
  final int currentIndex;

  const LyricsPage({
    Key? key,
    required this.songs,
    required this.song,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  late Song currentSong;

  @override
  void initState() {
    super.initState();
    currentSong = widget.songs[widget.currentIndex];
  }

  bool isFavorite() {
    // Check if the current song is in the favorites box
    var favoriteSongs = boxFavoriteSongs.values.toList();
    return favoriteSongs
        .any((favoriteSong) => favoriteSong.title == currentSong.title);
  }

  void toggleFavorite() {
    var favoriteSongKey = boxFavoriteSongs.keys.firstWhere(
      (key) {
        var favoriteSong = boxFavoriteSongs.get(key) as FavoriteSongs?;
        return favoriteSong != null && favoriteSong.title == currentSong.title;
      },
      orElse: () => null,
    );

    if (favoriteSongKey != null) {
      // If the current song is in favorites, remove it
      boxFavoriteSongs.delete(favoriteSongKey);

      // Show a Snackbar with the message "Removed from favorite songs"
      const snackBar = SnackBar(
        content: Text('Removed from favorite songs'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      // Otherwise, add the current song to favorites
      boxFavoriteSongs
          .add(FavoriteSongs(currentSong.title, currentSong.lyrics));

      // Show a Snackbar with the message "Added to favorite songs" and a "View" button
      final snackBar = SnackBar(
        content: const Text('Added to favorite songs'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to the favorite songs page when the "View" button is clicked
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FavoritesPage(),
              ),
            );
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    // Force a rebuild of the widget to update the favorite icon
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          "MUST FAM",
          style: TextStyle(
            fontSize: 19.51.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                iconSize: 25,
                icon: Icon(
                  isFavorite() ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite() ? Colors.red : null,
                ),
                onPressed: toggleFavorite,
              ),
            ],
          ),
        ],
      ),
      body: PageView.builder(
        itemCount: widget.songs.length,
        controller: PageController(initialPage: widget.currentIndex),
        onPageChanged: (index) {
          setState(() {
            currentSong = widget.songs[index];
          });
        },
        itemBuilder: (context, index) {
          return Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText(
                      widget.songs[index].title,
                      style: const TextStyle(
                        fontSize: 24,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                    child: SelectableText(
                      widget.songs[index].lyrics,
                      style: const TextStyle(
                        fontSize: 21,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
