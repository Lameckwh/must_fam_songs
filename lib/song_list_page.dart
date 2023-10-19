import 'package:flutter/material.dart';
import 'package:must_fam_songs/song.dart';
import 'package:must_fam_songs/song_lyrics_page.dart';

class SongListPage extends StatefulWidget {
  const SongListPage({super.key});

  @override
  _SongListPageState createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  List<Song> filteredSongs = List.from(songs);

  void filterSongs(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSongs = List.from(songs);
      } else {
        filteredSongs = songs
            .where((song) =>
                song.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        title: const Text('MUST FAM SONGS'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final String? result = await showSearch(
                context: context,
                delegate: SongSearchDelegate(),
              );
              filterSongs(result ??
                  'No Songs Founds'); // Provide a default empty string if 'result' is null
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(2.0), // Set the height of the bottom border
          child: Container(
            color: Colors.grey, // Set the border color
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredSongs.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                title: Text(
                  filteredSongs[index].title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LyricsPage(song: filteredSongs[index]),
                    ),
                  );
                },
              ),
              const Divider(
                // Add a divider (bottom border)
                color: Colors.grey,
                height: 1,
                thickness: 0.6,
                indent: 7,
                endIndent: 7,
              ),
            ],
          );
        },
      ),
    );
  }
}

class SongSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Search by Title';

  TextStyle customTextStyle = const TextStyle(
    fontFamily: 'Ubuntu', // Set the font family to 'Ubuntu'
    fontSize: 18.0, // Customize the font size
    fontWeight: FontWeight.normal, // Customize the font weight
    // Add other text style properties as needed
  );

// Set the placeholder text

  @override
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // This method is called when the user selects a search result.
    // You can return the selected item here if needed.
    return Center(
      child: Text(
        'Selected: $query',
        style: customTextStyle,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called as the user types in the search field.
    // You can provide suggestions based on the user's input.
    final suggestionList = songs
        .where((song) => song.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(
              title: Text(
                suggestionList[index].title,
                style: customTextStyle,
              ),
              onTap: () {
                close(context, suggestionList[index].title);
              },
            ),
            const Divider(
              // Add a divider (bottom border)
              color: Colors.grey,
              height: 1,
              thickness: 0.6,
              indent: 7,
              endIndent: 7,
            ),
          ],
        );
      },
    );
  }
}
