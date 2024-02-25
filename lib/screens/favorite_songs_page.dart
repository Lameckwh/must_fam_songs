import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:must_fam_songs/screens/favorite_lyrics_page.dart';
import 'package:must_fam_songs/model/boxes.dart';
import 'package:must_fam_songs/model/favorite_songs.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 1,
          title: const Text(
            'Favorite Songs',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            boxFavoriteSongs.isEmpty
                ? const Text("")
                : IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              'Confirm Deletion',
                              style: TextStyle(fontSize: 16),
                            ),
                            content: const Text(
                              'Are you sure you want to delete all favorite songs?',
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the confirmation dialog
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .red), // Set background color to red
                                    ),
                                    onPressed: () {
                                      // Delete the favorite tip when confirmed
                                      boxFavoriteSongs.clear();
                                      Navigator.of(context)
                                          .pop(); // Close the confirmation dialog
                                    },
                                    child: const Text(
                                      'Delete all',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  )
          ],
        ),
        body: ValueListenableBuilder<Box>(
          valueListenable: boxFavoriteSongs.listenable(),
          builder: (context, Box box, _) {
            List<int> keys = box.keys.cast<int>().toList();

            if (keys.isEmpty) {
              // Display the "Favorite tips will appear here" text when there are no favorite tips
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 50,
                      color: Colors.red,
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    const Text(
                      'Favorite songs will appear here',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Scrollbar(
              child: ListView.builder(
                itemCount: keys.length,
                itemBuilder: (context, index) {
                  int key = keys[index];
                  FavoriteSongs? favoriteSongs = box.get(key) as FavoriteSongs?;

                  return favoriteSongs != null
                      ? Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(0), // Adjust padding
                            child: ListTile(
                              title: Text(
                                overflow: TextOverflow
                                    .ellipsis, // Display ellipsis (...) at the end
                                maxLines: 1,
                                favoriteSongs.title,
                                style: const TextStyle(
                                    fontSize: 16), // Set font size
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FavoriteLyricsPage(
                                        favoriteSong: favoriteSongs),
                                  ),
                                );
                              },

                              trailing: GestureDetector(
                                onTap: () {
                                  // Show a confirmation dialog before deleting the favorite tip
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Confirm Deletion',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        content: const Text(
                                          'Are you sure you want to delete this favorite song?',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        actions: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the confirmation dialog
                                                },
                                                child: const Text(
                                                  'Cancel',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .all<Color>(Colors
                                                              .red), // Set background color to red
                                                ),
                                                onPressed: () {
                                                  // Delete the favorite tip when confirmed
                                                  box.delete(key);
                                                  Navigator.of(context)
                                                      .pop(); // Close the confirmation dialog
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Icon(
                                  Icons.cancel,
                                  size: 24,
                                  color: Colors.red,
                                ),
                              ),
                              // ...
                            ),
                          ),
                        )
                      : const Text(
                          "Empty",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black), // Set font size and color
                        );
                },
              ),
            );
          },
        ));
  }
}
