import 'package:flutter/material.dart';
import 'package:must_fam_songs/favorite_songs_page.dart';
import 'package:must_fam_songs/model/boxes.dart';
import 'package:must_fam_songs/model/favorite_songs.dart';
import 'package:must_fam_songs/song.dart';
// import "favorites_page.dart";

class LyricsPage extends StatefulWidget {
  final Song song;

  const LyricsPage({super.key, required this.song});

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  int currentIndex = 0;
  bool isFavorite(Song song) {
    // Check if the song is in the favorites box
    var favoriteSongs = boxFavoriteSongs.values.toList();
    return favoriteSongs
        .any((favoriteSong) => favoriteSong.title == song.title);
  }

  void toggleFavorite(Song song) {
    var favoriteSongKey = boxFavoriteSongs.keys.firstWhere(
      (key) {
        var favoriteSong = boxFavoriteSongs.get(key) as FavoriteSongs?;
        return favoriteSong != null && favoriteSong.title == song.title;
      },
      orElse: () => null,
    );

    if (favoriteSongKey != null) {
      // If a favorite song with the same title is found, remove it
      boxFavoriteSongs.delete(favoriteSongKey);

      // Show a Snackbar with the message "Removed from favorite songs"
      const snackBar = SnackBar(
        content: Text('Removed from favorite songs'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      // Otherwise, add the song to favorites
      boxFavoriteSongs.add(FavoriteSongs(song.title, song.lyrics));

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
        title: const Text("MUST FAM SONGS"),
        actions: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                iconSize: 25,
                icon: Icon(
                  isFavorite(widget.song)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite(widget.song) ? Colors.red : null,
                ),
                onPressed: () => toggleFavorite(widget.song),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              child: Text(
                widget.song.title,
                style: const TextStyle(
                  fontSize: 22,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  // fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              child: Text(
                widget.song.lyrics,
                style: const TextStyle(
                  fontSize: 19,
                  height: 1.5,
                  // fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
