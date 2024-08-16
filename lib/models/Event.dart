import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateOfEvent;
  final String imageUrl;
  final DateTime timestamp; // Add this field

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateOfEvent,
    required this.imageUrl,
    required this.timestamp, // Add this field
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dateOfEvent: (data['dateOfEvent'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(), // Extract timestamp
    );
  }
}
