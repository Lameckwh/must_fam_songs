import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:must_fam_songs/fam_events/events/edit_event.dart';
import 'package:must_fam_songs/fam_events/events/event_details.dart';

class EventList extends StatefulWidget {
  const EventList({super.key});

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  void _confirmDeleteEvent(
      BuildContext context, String documentId, String? imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteEvent(documentId, imageUrl);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(String documentId, String? imageUrl) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(documentId)
        .delete();

    if (imageUrl != null) {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
                'Error fetching data. Please check your network connection.'),
          );
        }

        final events = snapshot.data!.docs;

        if (events.isEmpty) {
          return Column(
            children: [
              SizedBox(height: 16.h),
              const Center(
                child: Text('No Events Posted Yet'),
              ),
            ],
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final title = event['title'];
            final description = event['description'];
            final dateOfEvent = (event['dateOfEvent'] as Timestamp).toDate();
            final imageUrl = event['imageUrl'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetails(
                      title: title,
                      description: description,
                      dateOfEvent:
                          dateOfEvent, // Use dateOfEvent instead of datePosted
                      imageUrl: imageUrl,
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 35.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.0.h),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 20.0.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0.h),
                                  // const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.event,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10.0.w),
                                      Text(
                                        formattedDate(dateOfEvent),
                                        overflow: TextOverflow.fade,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    thickness: 2,
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  Text(
                                    _truncateDescription(description),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  tooltip: 'Delete Event',
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    _confirmDeleteEvent(
                                        context, event.id, event['imageUrl']);
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Edit Event',
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditEventForm(
                                          documentId: event.id,
                                          title: event['title'],
                                          description: event['description'],
                                          dateOfEvent: (event['dateOfEvent']
                                                  as Timestamp)
                                              .toDate(),
                                          imageUrl: event['imageUrl'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String formattedDate(DateTime date) {
    return DateFormat('HH:mm, d MMM y').format(date);
  }

  String _truncateDescription(String description) {
    const int maxLength = 250;
    return description.length > maxLength
        ? '${description.substring(0, maxLength)}...'
        : description;
  }
}
