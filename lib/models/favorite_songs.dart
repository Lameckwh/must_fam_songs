import 'package:hive/hive.dart';

part 'favorite_songs.g.dart'; // Name of the generated adapter file

@HiveType(typeId: 0)
class FavoriteSongs {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String lyrics;

  FavoriteSongs(this.title, this.lyrics);
}
