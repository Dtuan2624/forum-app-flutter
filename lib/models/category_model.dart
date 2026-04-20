import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final DateTime? createdAt;

  CategoryModel({required this.id, required this.name, this.createdAt});

  factory CategoryModel.fromMap(String id, Map<String, dynamic> data) {
    final rawCreatedAt = data['createdAt'];
    DateTime? createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } else if (rawCreatedAt is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    }

    return CategoryModel(
      id: id,
      name: data['name'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}
