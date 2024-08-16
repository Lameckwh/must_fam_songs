import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:must_fam_songs/fam_events/events/event_details.dart';

class EventList extends StatefulWidget {
  const EventList({super.key});

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
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
          return Center(
            child: Text(
              'There are no events at this moment',
              style: TextStyle(fontSize: 16.sp),
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final title = event['title'];
            final description = event['description'];
            final imageUrl = event['imageUrl'];
            final dateOfEvent = (event['dateOfEvent'] as Timestamp).toDate();

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetails(
                      title: title,
                      description: description,
                      dateOfEvent: dateOfEvent,
                      imageUrl: '', // Remove imageUrl since it's not used
                    ),
                  ),
                );
              },
              child: Card(
                margin:
                    EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 12.0.h),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Stack(
                    children: [
                      // Dark Blue Gradient Background
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height *
                            0.8.h, // Match this height with the EventList section height
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 3, 30, 59),
                              Color.fromARGB(255, 29, 72, 109)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      // Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                      // Event Details
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(16.0.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 18.0.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8.0.h),
                                  Chip(
                                    label: Text(
                                      formattedDate(dateOfEvent),
                                      style: TextStyle(
                                        fontSize: 14.0.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.black87,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0.h),
                              // Read More Button at the Bottom Center
                              Center(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventDetails(
                                          title: title,
                                          description: description,
                                          dateOfEvent: dateOfEvent,
                                          imageUrl:
                                              imageUrl, // Remove imageUrl since it's not used
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16.0.sp,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Read More',
                                    style: TextStyle(
                                      fontSize: 14.0.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0.w, vertical: 8.0.h),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
}
