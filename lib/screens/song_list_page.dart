import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:must_fam_songs/song.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:must_fam_songs/screens/song_lyrics_page.dart';

class SongListPage extends StatefulWidget {
  const SongListPage({super.key});

  @override
  _SongListPageState createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  List<Song> filteredSongs = List.from(songs);
  late ScrollController _scrollController;
  bool _showGreenLine = true; // Flag to show/hide the green line

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showGreenLine =
              _scrollController.offset == 0; // Show line only when at the top
        });
      });
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // Dispose of the controller when the widget is removed
    super.dispose();
  }

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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(2.h),
              child: _showGreenLine
                  ? Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 10.w),
                        color: Colors.green,
                        height: 5.h,
                        width: 50.w,
                      ),
                    )
                  : const SizedBox.shrink(), // Hide the line when not needed
            ),
            surfaceTintColor: Colors.green,
            pinned: true,
            expandedHeight: 85.h, // Adjust height as needed
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 10.w, bottom: 10),
              title: Text(
                'MUST FAM',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
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
              ValueListenableBuilder(
                valueListenable: Hive.box('settings').listenable(),
                builder: (context, box, child) {
                  final isDark = box.get("isDark", defaultValue: false);
                  return IconButton(
                    icon: Icon(
                      isDark ? Icons.brightness_3 : Icons.brightness_6,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      box.put("isDark", !isDark);
                      // Refresh the AppBar after changing the theme
                      setState(() {});
                    },
                  );
                },
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Column(
                  children: [
                    Divider(
                      color: Colors.grey,
                      height: 1.h,
                      thickness: 0.6,
                      indent: 7.w,
                      endIndent: 7.w,
                    ),
                    ListTile(
                      title: Text(
                        overflow: TextOverflow.ellipsis,
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
                  ],
                );
              },
              childCount: filteredSongs.length,
            ),
          ),
        ],
      ),
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
      itemBuilder: (context, index) => ListTile(
        title: Text(
          suggestionList[index].title,
          style: customTextStyle,
        ),
        onTap: () {
          close(context, suggestionList[index].title);
        },
      ),
      itemCount: suggestionList.length,
    );
  }
}
