import 'package:adhan_dart/adhan_dart.dart';
import '../entities/prayer_time.dart';

abstract class PrayerRepository {
  Future<List<PrayerTime>> getPrayerTimes(Coordinates coordinates, DateTime date);
  Future<String> getRemainingTime(Coordinates coordinates, DateTime date);
}
