import 'package:flutter/material.dart';
import 'package:must_fam_songs/model/favorite_songs.dart';

class FavoriteLyricsPage extends StatelessWidget {
  final FavoriteSongs favoriteSong;

  const FavoriteLyricsPage({Key? key, required this.favoriteSong})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          "MUST FAM",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                favoriteSong.title,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  // fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              child: SelectableText(
                favoriteSong.lyrics,
                style: const TextStyle(
                  fontSize: 21,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
