import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:must_fam_songs/song.dart';
import 'package:must_fam_songs/screens/song_lyrics_page.dart';

class SongListPage extends StatefulWidget {
  const SongListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 1,
            title: const Text(
              'MUST FAM',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final String? result = await showSearch(
                    context: context,
                    delegate: SongSearchDelegate(),
                  );
                  filterSongs(result ?? 'No Songs Found');
                },
              ),
              // IconButton(onPressed: () {}, icon: const Icon(Icons.person))
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(2.h),
              child: Container(
                color: Colors.grey,
              ),
            ),
          ),
          body: Scrollbar(
            child: ListView.builder(
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        overflow: TextOverflow
                            .ellipsis, // Display ellipsis (...) at the end
                        maxLines: 1,
                        filteredSongs[index].title,
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LyricsPage(
                              songs: filteredSongs,
                              song: filteredSongs[index],
                              currentIndex: index,
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 1.h,
                      thickness: 0.6,
                      indent: 7.w,
                      endIndent: 7.w,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class SongSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Search by Title';

  TextStyle customTextStyle = TextStyle(
    fontFamily: 'ProximaSoft',
    fontSize: 18.sp,
    fontWeight: FontWeight.normal,
  );

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
    return Center(
      child: Text(
        'Selected: $query',
        style: customTextStyle,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
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
                overflow:
                    TextOverflow.ellipsis, // Display ellipsis (...) at the end
                maxLines: 1,
                suggestionList[index].title,
                style: customTextStyle,
              ),
              onTap: () {
                close(context, suggestionList[index].title);
              },
            ),
            Divider(
              color: Colors.grey,
              height: 1.h,
              thickness: 0.6,
              indent: 7.w,
              endIndent: 7.w,
            ),
          ],
        );
      },
    );
  }
}
