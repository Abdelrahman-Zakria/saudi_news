import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/directory_contact.dart';

class DirectoryContactModel extends DirectoryContact {
  DirectoryContactModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.category,
    super.email,
    super.region,
    super.website,
    required super.source,
  });

  factory DirectoryContactModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DirectoryContactModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      category: data['category'] ?? 'عام',
      email: data['email'],
      region: data['region'],
      website: data['website'],
      source: data['source'] ?? 'unknown',
    );
  }

  static Map<String, dynamic> toMap(DirectoryContact contact) {
    return {
      'name': contact.name,
      'phone': contact.phone,
      'category': contact.category,
      'email': contact.email,
      'region': contact.region,
      'website': contact.website,
      'source': contact.source,
    };
  }
}
