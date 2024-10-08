import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:must_fam_songs/fam_events/announcements/announcement_detail.dart';

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
          return Column(
            children: [
              SizedBox(height: 20.h),
              const Text('There are no announcements at this moment'),
            ],
          );
        }

        return ListView.builder(
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            final title = announcement['title'];
            final description = announcement['description'];
            final datePosted =
                (announcement['datePosted'] as Timestamp).toDate();
            final imageUrl = announcement['imageUrl'];

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.all(8.0),
                child: InkWell(
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18.0.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8.0.h),
                              Text(
                                _truncateDescription(description),
                                style: TextStyle(fontSize: 14.0.sp),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8.0.h),
                              Text(
                                formattedDate(datePosted),
                                style: TextStyle(
                                  fontSize: 12.0.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
    const int maxLength = 100;
    return description.length > maxLength
        ? '${description.substring(0, maxLength)}...'
        : description;
  }
}
