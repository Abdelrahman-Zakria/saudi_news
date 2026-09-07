import 'package:equatable/equatable.dart';
import '../../domain/entities/prayer_time.dart';

abstract class PrayerState extends Equatable {
  const PrayerState();

  @override
  List<Object?> get props => [];
}

class PrayerInitial extends PrayerState {}

class PrayerLoading extends PrayerState {}

class PrayerLoaded extends PrayerState {
  final List<PrayerTime> prayerTimes;
  final String nextPrayerName;
  final String remainingTime;
  final String cityName;

  const PrayerLoaded({
    required this.prayerTimes,
    required this.nextPrayerName,
    required this.remainingTime,
    required this.cityName,
  });

  @override
  List<Object?> get props => [prayerTimes, nextPrayerName, remainingTime, cityName];
}

class PrayerError extends PrayerState {
  final String message;

  const PrayerError(this.message);

  @override
  List<Object?> get props => [message];
}
