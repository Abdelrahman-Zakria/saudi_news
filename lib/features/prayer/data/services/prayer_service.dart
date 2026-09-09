import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/prayer_time.dart';

class PrayerService {
  List<PrayerTime> getPrayerTimes(Coordinates coordinates, DateTime date) {
    CalculationParameters params = CalculationMethodParameters.ummAlQura();
    PrayerTimes prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
      precision: true,
    );

    final nextPrayer = prayerTimes.nextPrayer();

    return [
      _mapToEntity('الفجر', prayerTimes.fajr, '🌙', nextPrayer == Prayer.fajr),
      _mapToEntity('الشروق', prayerTimes.sunrise, '🌅', nextPrayer == Prayer.sunrise),
      _mapToEntity('الظهر', prayerTimes.dhuhr, '☀️', nextPrayer == Prayer.dhuhr),
      _mapToEntity('العصر', prayerTimes.asr, '🌇', nextPrayer == Prayer.asr),
      _mapToEntity('المغرب', prayerTimes.maghrib, '🌆', nextPrayer == Prayer.maghrib),
      _mapToEntity('العشاء', prayerTimes.isha, '🌃', nextPrayer == Prayer.isha),
    ];
  }

  PrayerTime _mapToEntity(String name, DateTime time, String icon, bool isNext) {
    return PrayerTime(
      name: name,
      time: DateFormat.jm().format(time.toLocal()),
      icon: icon,
      isNext: isNext,
    );
  }

  String getRemainingTime(PrayerTimes prayerTimes) {
    final next = prayerTimes.nextPrayer();
    // In adhan_dart, nextPrayer() returns a valid Prayer enum (e.g. fajrafter if day is over)
    final nextTime = prayerTimes.timeForPrayer(next);

    final now = DateTime.now();
    final duration = nextTime.difference(now);
    
    if (duration.isNegative) return '00:00:00';

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return '$hours:$minutes:$seconds';
  }
}
