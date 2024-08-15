import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateOfEvent;
  final String imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateOfEvent,
    required this.imageUrl,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dateOfEvent: (data['dateOfEvent'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
