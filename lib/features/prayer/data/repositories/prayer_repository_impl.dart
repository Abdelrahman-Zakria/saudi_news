import 'package:adhan_dart/adhan_dart.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../services/prayer_service.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerService _prayerService;

  PrayerRepositoryImpl(this._prayerService);

  @override
  Future<List<PrayerTime>> getPrayerTimes(Coordinates coordinates, DateTime date) async {
    return _prayerService.getPrayerTimes(coordinates, date);
  }

  @override
  Future<String> getRemainingTime(Coordinates coordinates, DateTime date) async {
    final params = CalculationMethodParameters.ummAlQura();
    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
      precision: true,
    );
    return _prayerService.getRemainingTime(prayerTimes);
  }
}
