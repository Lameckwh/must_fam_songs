import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:must_fam_songs/fam_events/announcements/announcement_form.dart';
import 'package:must_fam_songs/fam_events/announcements/announcements_list.dart';
import 'package:must_fam_songs/fam_events/events/event_list.dart';
import 'package:must_fam_songs/fam_events/events/events_form.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  // Add a GlobalKey for the RefreshIndicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Add a function to handle the refresh
  Future<void> _handleRefresh() async {
    // You can perform any asynchronous operation here
    // For example, fetch new data from a server
    // After completing the operation, call setState to rebuild the UI
    setState(() {
      // Update your data here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('FAM Events'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          child: Scrollbar(
            scrollbarOrientation: ScrollbarOrientation.right,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Section for Announcements
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Events',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Add New Event',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EventsForm(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_outlined,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3.h,
                    child: const Scrollbar(
                      child: EventList(),
                    ),
                  ), // Adjust the height as needed
                  // Section for Events
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Announcements',
                          style: TextStyle(
                            fontSize: 20.0.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Add New Announcement',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AnnouncementForm(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_outlined,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7.h,
                    child: const AnnouncementList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
