import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../domain/entities/directory_contact.dart';
import '../models/directory_contact_model.dart';
import '../../../../core/services/settings_service.dart';

class DirectoryRepositoryImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _settingsService = SettingsService();

  Stream<List<DirectoryContact>> getContactsStream({String? query}) {
    Query firestoreQuery = _firestore.collection('phone_directory');
    
    if (query != null && query.isNotEmpty) {
      firestoreQuery = firestoreQuery
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff');
    }

    return firestoreQuery.limit(100).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DirectoryContactModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> syncLocalContacts() async {
    if (_settingsService.contactsSynced) return;

    // Correct permission request for flutter_contacts ^2.3.1
    // It requires a PermissionType and returns a PermissionStatus
    final PermissionStatus status = await FlutterContacts.permissions.request(PermissionType.read);
    final bool permissionGranted = status == PermissionStatus.granted;
    
    if (permissionGranted) {
      // Correct fetching method for flutter_contacts ^2.3.1
      // Fetching all contacts with phone properties
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

          // Correct Firestore method is .doc(), not .document()
          final DocumentReference docRef = _firestore.collection('phone_directory').doc(normalized);
          
          batch.set(docRef, {
            'name': contact.displayName,
            'phone': normalized,
            'category': 'جهة اتصال شخصية',
            'source': 'user_contacts',
            'last_sync': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          
          count++;
          // Firestore batches are limited to 500 operations
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