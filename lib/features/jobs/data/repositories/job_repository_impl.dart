import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/job.dart';
import '../models/job_model.dart';

class JobRepositoryImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Job>> getJobsStream() {
    return _firestore
        .collection('jobs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
    });
  }

  // Used for testing/fallback if needed
  List<Job> getDummyJobs() {
    return [];
  }
}
