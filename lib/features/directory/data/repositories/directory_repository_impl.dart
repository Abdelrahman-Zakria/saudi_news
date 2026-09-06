import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../domain/entities/directory_contact.dart';
import '../models/directory_contact_model.dart';
import '../../../../core/services/settings_service.dart';

class DirectoryRepositoryImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _settingsService = SettingsService();

  Stream<List<DirectoryContact>> getContactsStream({String? query, String? category, int limit = 20}) {
    CollectionReference collection = _firestore.collection('phone_directory');
    Query firestoreQuery = collection;
    
    // Filter by Category if specified
    if (category != null && category != "الكل") {
      firestoreQuery = firestoreQuery.where('category', isEqualTo: category);
    }

    if (query != null && query.isNotEmpty) {
      final bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(query);
      
      if (isNumeric) {
        firestoreQuery = firestoreQuery
            .where('phone', isGreaterThanOrEqualTo: query)
            .where('phone', isLessThanOrEqualTo: query + '\uf8ff');
      } else {
        firestoreQuery = firestoreQuery
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff');
      }
    }

    // CRITICAL: We removed orderBy from Firestore to avoid "Missing Index" errors.
    // We fetch a bit more than the limit to handle memory sorting and then truncate.
    return firestoreQuery.limit(limit * 2).snapshots().map((snapshot) {
      final contacts = snapshot.docs.map((doc) => DirectoryContactModel.fromFirestore(doc)).toList();
      
      // Memory Sorting: Ensure 'طوارئ' is ALWAYS at the absolute top
      contacts.sort((a, b) {
        if (a.category == 'طوارئ' && b.category != 'طوارئ') return -1;
        if (a.category != 'طوارئ' && b.category == 'طوارئ') return 1;
        return a.name.compareTo(b.name);
      });
      
      // Apply the actual requested limit after sorting
      if (contacts.length > limit) {
        return contacts.sublist(0, limit);
      }
      return contacts;
    });
  }

  Future<void> syncLocalContacts() async {
    if (_settingsService.contactsSynced) return;

    final PermissionStatus status = await FlutterContacts.permissions.request(PermissionType.read);
    final bool permissionGranted = status == PermissionStatus.granted;
    
    if (permissionGranted) {
      final List<Contact> contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone},
      );
      
      final WriteBatch batch = _firestore.batch();
      int count = 0;

      for (var contact in contacts) {
        if (contact.phones.isEmpty) continue;

        for (var phone in contact.phones) {
          final String normalized = _normalizePhone(phone.number);
          if (normalized.isEmpty) continue;

          final DocumentReference docRef = _firestore.collection('phone_directory').doc(normalized);
          
          batch.set(docRef, {
            'name': contact.displayName,
            'phone': normalized,
            'category': 'جهة اتصال شخصية',
            'source': 'user_contacts',
            'last_sync': FieldValue.serverTimestamp(),
            'is_emergency': false,
          }, SetOptions(merge: true));
          
          count++;
          if (count >= 500) {
            await batch.commit();
            await _settingsService.setContactsSynced(true);
            return; 
          }
        }
      }
      
      if (count > 0) {
        await batch.commit();
        await _settingsService.setContactsSynced(true);
      }
    }
  }

  String _normalizePhone(String phone) {
    String s = phone.replaceAll(RegExp(r'\D'), '');
    if (s.startsWith('05')) {
      s = '966' + s.substring(1);
    } else if (s.startsWith('5') && s.length == 9) {
      s = '966' + s;
    }
    return s;
  }
}
