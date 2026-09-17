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

    final bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(query.replaceAll(RegExp(r'\s+'), ''));
    CollectionReference collection = _firestore.collection('phone_directory');

    if (isNumeric) {
      // 1. CLEAN input and get the core digits
      String digits = query.replaceAll(RegExp(r'\D'), '');
      if (digits.startsWith('00966')) digits = digits.substring(5);
      else if (digits.startsWith('966')) digits = digits.substring(3);
      else if (digits.startsWith('0')) digits = digits.substring(1);

      // 2. We search for ALL common Saudi formats as prefixes
      final List<String> variations = [
        digits,           // 54...
        '0' + digits,     // 054...
        '966' + digits,   // 96654...
        '00966' + digits, // 0096654...
      ];

      final futures = variations.map((v) => collection
          .where('phone', isGreaterThanOrEqualTo: v)
          .where('phone', isLessThanOrEqualTo: v + '\uf8ff')
          .limit(limit)
          .get()
      ).toList();

      return Stream.fromFuture(Future.wait(futures)).map((snapshots) {
        final List<DirectoryContact> results = [];
        final Set<String> seenIds = {};

        for (var snap in snapshots) {
          for (var doc in snap.docs) {
            if (!seenIds.contains(doc.id)) {
              results.add(DirectoryContactModel.fromFirestore(doc));
              seenIds.add(doc.id);
            }
          }
        }
        
        results.sort((a, b) {
          if (a.category == 'طوارئ' && b.category != 'طوارئ') return -1;
          if (a.category != 'طوارئ' && b.category == 'طوارئ') return 1;
          return a.name.compareTo(b.name);
        });

        return results.length > limit ? results.sublist(0, limit) : results;
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
      
      WriteBatch batch = _firestore.batch();
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
            batch = _firestore.batch();
            count = 0;
          }
        }
      }
      
      if (count > 0) {
        await batch.commit();
      }
      await _settingsService.setContactsSynced(true);
    }
  }

  String _normalizePhone(String phone) {
    String s = phone.replaceAll(RegExp(r'\D'), '');
    if (s.isEmpty) return "";
    
    if (s.startsWith('00966')) s = s.substring(2);
    if (s.startsWith('05')) {
      s = '966' + s.substring(1);
    } else if (s.startsWith('5') && s.length == 9) {
      s = '966' + s;
    }
    return s;
  }

  Future<List<DirectoryContact>> lookupNumber(String number) async {
    String digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return [];
    
    if (digits.startsWith('00966')) digits = digits.substring(5);
    else if (digits.startsWith('966')) digits = digits.substring(3);
    else if (digits.startsWith('0')) digits = digits.substring(1);
    
    final List<String> variations = [
      digits,
      '0' + digits,
      '966' + digits,
      '00966' + digits,
    ];

    final List<Future<QuerySnapshot>> queries = variations.map((v) => 
      _firestore.collection('phone_directory')
          .where('phone', isGreaterThanOrEqualTo: v)
          .where('phone', isLessThanOrEqualTo: v + '\uf8ff')
          .limit(10)
          .get()
    ).toList();

    final snapshots = await Future.wait(queries);
    final results = <DirectoryContact>[];
    final Set<String> seenIds = {};

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
