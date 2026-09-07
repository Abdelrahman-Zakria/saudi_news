import 'dart:async';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/prayer_repository_impl.dart';
import '../../data/services/prayer_service.dart';
import 'prayer_state.dart';
import '../../../../core/constants/saudi_cities.dart';

class PrayerCubit extends Cubit<PrayerState> {
  final PrayerRepositoryImpl _repository = PrayerRepositoryImpl(PrayerService());
  Timer? _timer;
  Coordinates _currentCoords = Coordinates(24.7136, 46.6753); // Default Riyadh
  String _currentCity = "الرياض";

  PrayerCubit() : super(PrayerInitial());

  Future<void> init() async {
    await _determinePosition();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  Future<void> _determinePosition() async {
    emit(PrayerLoading());
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the 
        // App to enable the location services.
        _loadForCoords(_currentCoords, _currentCity);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _loadForCoords(_currentCoords, _currentCity);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _loadForCoords(_currentCoords, _currentCity);
        return;
      } 

      Position position = await Geolocator.getCurrentPosition();
      _currentCoords = Coordinates(position.latitude, position.longitude);
      _currentCity = "موقعي الحالي";
      _loadForCoords(_currentCoords, _currentCity);
    } catch (e) {
      _loadForCoords(_currentCoords, _currentCity);
    }
  }

  Future<void> changeCity(CityModel city) async {
    _currentCoords = Coordinates(city.latitude, city.longitude);
    _currentCity = city.name;
    _loadForCoords(_currentCoords, _currentCity);
  }

  Future<void> _loadForCoords(Coordinates coords, String cityName) async {
    final now = DateTime.now();
    final prayerTimes = await _repository.getPrayerTimes(coords, now);
    
    final params = CalculationMethodParameters.ummAlQura();
    final adhanTimes = PrayerTimes(
      coordinates: coords,
      date: now,
      calculationParameters: params,
      precision: true,
    );
    
    final next = adhanTimes.nextPrayer();
    final nextName = _getPrayerName(next);
    final remaining = await _repository.getRemainingTime(coords, now);

    emit(PrayerLoaded(
      prayerTimes: prayerTimes,
      nextPrayerName: nextName,
      remainingTime: remaining,
      cityName: cityName,
    ));
  }

  Future<void> _updateRemainingTime() async {
    if (state is PrayerLoaded) {
      final s = state as PrayerLoaded;
      final remaining = await _repository.getRemainingTime(_currentCoords, DateTime.now());
      
      if (remaining == "00:00:00") {
        _loadForCoords(_currentCoords, _currentCity);
      } else {
        emit(PrayerLoaded(
          prayerTimes: s.prayerTimes,
          nextPrayerName: s.nextPrayerName,
          remainingTime: remaining,
          cityName: s.cityName,
        ));
      }
    }
  }

  String _getPrayerName(Prayer prayer) {
    switch(prayer) {
      case Prayer.fajr: return "الفجر";
      case Prayer.sunrise: return "الشروق";
      case Prayer.dhuhr: return "الظهر";
      case Prayer.asr: return "العصر";
      case Prayer.maghrib: return "المغرب";
      case Prayer.isha: return "العشاء";
      default: return "الفجر";
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
