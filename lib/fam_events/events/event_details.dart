import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetails extends StatelessWidget {
  final String title;
  final String description;
  final DateTime dateOfEvent;
  final String? imageUrl;

  const EventDetails({
    Key? key,
    required this.title,
    required this.description,
    required this.dateOfEvent,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl!,
                placeholder: (context, url) => const SizedBox(
                  width: 200.0, // Adjust the width as needed
                  height: 200.0, // Adjust the height as needed
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                      strokeWidth: 2.0, // Adjust the strokeWidth as needed
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                height: 200.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16.0),
            Text(
              'Scheduled on ${formattedDate(dateOfEvent)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style:
                  const TextStyle(fontSize: 19.0, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10.0),
            Text(
              description,
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  String formattedDate(DateTime date) {
    return DateFormat('HH:mm, d MMM y').format(date);
  }
}
