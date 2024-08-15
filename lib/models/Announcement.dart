import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String description;
  final DateTime datePosted;
  final String imageUrl;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.datePosted,
    required this.imageUrl,
  });

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Announcement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      datePosted: (data['datePosted'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
