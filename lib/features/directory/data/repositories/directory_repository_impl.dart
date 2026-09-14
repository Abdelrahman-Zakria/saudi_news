import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../domain/entities/directory_contact.dart';
import '../models/directory_contact_model.dart';
import '../../../../core/services/settings_service.dart';

class DirectoryRepositoryImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _settingsService = SettingsService();

  Future<List<DirectoryContact>> getLocalContacts() async {
    final status = await FlutterContacts.permissions.request(PermissionType.read);
    
    if (status == PermissionStatus.granted) {
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone},
      );
      
      return contacts.map((c) => DirectoryContact(
        id: c.id ?? '',
        name: c.displayName ?? '',
        phone: c.phones.isNotEmpty ? (c.phones.first.number) : '',
        category: 'جهة اتصال شخصية',
        source: 'local',
        isEmergency: false,
      )).where((c) => c.phone.isNotEmpty).toList();
    }
    return [];
  }

  Stream<List<DirectoryContact>> searchFirestoreContacts({String? query, int limit = 20}) {
    if (query == null || query.isEmpty) {
      return Stream.value([]);
    }

    final bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(query);
    CollectionReference collection = _firestore.collection('phone_directory');

    if (isNumeric) {
      // For phone numbers, we perform two queries to handle both 966 and local formats
      String clean = query.replaceAll(RegExp(r'\D'), '');
      if (clean.startsWith('0')) clean = clean.substring(1);
      if (clean.startsWith('966')) clean = clean.substring(3);

      final String with966 = '966' + clean;

      // Firestore doesn't support OR with prefix, so we run them and merge
      final stream1 = collection
          .where('phone', isGreaterThanOrEqualTo: clean)
          .where('phone', isLessThanOrEqualTo: clean + '\uf8ff')
          .limit(limit)
          .snapshots();

      final stream2 = collection
          .where('phone', isGreaterThanOrEqualTo: with966)
          .where('phone', isLessThanOrEqualTo: with966 + '\uf8ff')
          .limit(limit)
          .snapshots();

      // Simple merge of the two streams
      return stream1.asyncMap((snap1) async {
        final snap2 = await collection
            .where('phone', isGreaterThanOrEqualTo: with966)
            .where('phone', isLessThanOrEqualTo: with966 + '\uf8ff')
            .limit(limit)
            .get();
        
        final results = <DirectoryContact>[];
        final seenIds = <String>{};

        for (var doc in [...snap1.docs, ...snap2.docs]) {
          if (!seenIds.contains(doc.id)) {
            results.add(DirectoryContactModel.fromFirestore(doc));
            seenIds.add(doc.id);
          }
        }
        return results;
      });
    } else {
      // Name search
      return collection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => DirectoryContactModel.fromFirestore(doc)).toList());
    }
  }

  Future<void> syncLocalContacts() async {
    if (_settingsService.contactsSynced) return;

    final status = await FlutterContacts.permissions.request(PermissionType.read);
    
    if (status == PermissionStatus.granted) {
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
            'name': contact.displayName ?? 'بدون اسم',
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
    // Standardize to 966 format for the database
    if (s.startsWith('0')) {
      s = '966' + s.substring(1);
    } else if (s.startsWith('5') && s.length == 9) {
      s = '966' + s;
    }
    return s;
  }

  Future<List<DirectoryContact>> lookupNumber(String number) async {
    String clean = number.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return [];
    
    // Format input for search
    String searchLocal = clean;
    if (searchLocal.startsWith('0')) searchLocal = searchLocal.substring(1);
    if (searchLocal.startsWith('966')) searchLocal = searchLocal.substring(3);
    
    final String searchWith966 = '966' + searchLocal;

    final List<Future<QuerySnapshot>> queries = [
      _firestore.collection('phone_directory')
          .where('phone', isGreaterThanOrEqualTo: searchLocal)
          .where('phone', isLessThanOrEqualTo: searchLocal + '\uf8ff')
          .limit(5)
          .get(),
      _firestore.collection('phone_directory')
          .where('phone', isGreaterThanOrEqualTo: searchWith966)
          .where('phone', isLessThanOrEqualTo: searchWith966 + '\uf8ff')
          .limit(5)
          .get(),
    ];

    final snapshots = await Future.wait(queries);
    final results = <DirectoryContact>[];
    final seenIds = <String>{};

    for (var snap in snapshots) {
      for (var doc in snap.docs) {
        if (!seenIds.contains(doc.id)) {
          results.add(DirectoryContactModel.fromFirestore(doc));
          seenIds.add(doc.id);
        }
      }
    }

    return results;
  }
}
