import 'package:cloud_firestore/cloud_firestore.dart';

import 'PlayerStats.dart';

class BoardGame {
  final String title;
  final int year;
  final DateTime lastPlayed;
  final int totalPlays;
  final List<String> images;
  final List<PlayerStats> winners;

  BoardGame({
    required this.title,
    required this.year,
    required this.lastPlayed,
    required this.totalPlays,
    required this.images,
    required this.winners,
  });

  factory BoardGame.fromFirestore(Map<String, dynamic> data) {
    return BoardGame(
      title: data['title'] ?? 'Unknown',
      year: data['year'] ?? 0,
      lastPlayed: (data['lastPlayed'] as Timestamp).toDate(),
      totalPlays: data['totalPlays'] ?? 0,
      images: List<String>.from(data['images'] ?? []),
      winners: List<PlayerStats>.from(
        (data['winners'] ?? []).map((p) => PlayerStats.fromMap(p))),
    );
  }

  factory BoardGame.fromFirestore2(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return BoardGame(
    title: data['title'],
    year: data['year'],
    lastPlayed: (data['lastPlayed'] as Timestamp).toDate(),
    totalPlays: data['totalPlays'],
    images: List<String>.from(data['images']),
    winners: List<Map<String, dynamic>>.from(data['winners'])
        .map((w) => PlayerStats.fromMap(w))
        .toList(),
  );
}
}