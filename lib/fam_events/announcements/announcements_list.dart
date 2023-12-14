import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:must_fam_songs/fam_events/announcements/announcement_detail.dart';
import 'package:must_fam_songs/fam_events/announcements/edit_announcement.dart';

class AnnouncementList extends StatefulWidget {
  const AnnouncementList({super.key});

  @override
  State<AnnouncementList> createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('announcements').snapshots(),
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

        final announcements = snapshot.data!.docs;

        if (announcements.isEmpty) {
          return const Center(
            child: Text('No Announcement Posted Yet'),
          );
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            final title = announcement['title'];
            final description = announcement['description'];
            final datePosted =
                (announcement['datePosted'] as Timestamp).toDate();
            final imageUrl = announcement['imageUrl'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnnouncementDetail(
                      title: title,
                      description: description,
                      datePosted: datePosted,
                      imageUrl: imageUrl,
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 8.0.h),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 240.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 18.0.h,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _truncateDescription(description),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.0.h),
                                Text(
                                  formattedDate(datePosted),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          tooltip: 'Delete Announcement',
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _deleteAnnouncement(
                                context, announcement.id, imageUrl);
                          },
                        ),
                        IconButton(
                          tooltip: 'Edit Announcement',
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditAnnouncementForm(
                                  documentId: announcement.id,
                                  title: title,
                                  description: description,
                                  imageUrl: imageUrl,
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
    const int maxLength = 70;
    return description.length > maxLength
        ? '${description.substring(0, maxLength)}...'
        : description;
  }

  void _deleteAnnouncement(
      BuildContext context, String documentId, String? imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this announcement?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _performDeleteAnnouncement(documentId, imageUrl);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _performDeleteAnnouncement(String documentId, String? imageUrl) async {
    await FirebaseFirestore.instance
        .collection('announcements')
        .doc(documentId)
        .delete();

    if (imageUrl != null) {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
    }
  }
}
