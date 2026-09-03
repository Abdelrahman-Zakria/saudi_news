import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhan_dart/adhan_dart.dart';
import '../../data/repositories/prayer_repository_impl.dart';
import '../../data/services/prayer_service.dart';
import '../../domain/entities/prayer_time.dart';
import '../widgets/qibla_compass.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late PrayerRepositoryImpl _prayerRepository;
  List<PrayerTime> _prayerTimes = [];
  String _remainingTime = "00:00:00";
  String _nextPrayerName = "";
  Timer? _timer;
  final Coordinates _riyadhCoords = Coordinates(24.7136, 46.6753);

  @override
  void initState() {
    super.initState();
    _prayerRepository = PrayerRepositoryImpl(PrayerService());
    _loadPrayerData();
    
    // Timer to update remaining time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerData() async {
    final now = DateTime.now();
    final times = await _prayerRepository.getPrayerTimes(_riyadhCoords, now);
    
    // Determine next prayer using adhan_dart logic
    final params = CalculationMethodParameters.ummAlQura();
    final adhanTimes = PrayerTimes(
      coordinates: _riyadhCoords,
      date: now,
      calculationParameters: params,
      precision: true,
    );
    
    final next = adhanTimes.nextPrayer();
    String nextName = "";
    switch(next) {
      case Prayer.fajr: nextName = "الفجر"; break;
      case Prayer.sunrise: nextName = "الشروق"; break;
      case Prayer.dhuhr: nextName = "الظهر"; break;
      case Prayer.asr: nextName = "العصر"; break;
      case Prayer.maghrib: nextName = "المغرب"; break;
      case Prayer.isha: nextName = "العشاء"; break;
      default: nextName = "الفجر";
    }

    if (mounted) {
      setState(() {
        _prayerTimes = times;
        _nextPrayerName = nextName;
      });
      _updateRemainingTime();
    }
  }

  Future<void> _updateRemainingTime() async {
    final remaining = await _prayerRepository.getRemainingTime(_riyadhCoords, DateTime.now());
    if (mounted) {
      setState(() {
        _remainingTime = remaining;
      });
      
      // If remaining is 00:00:00, it might mean prayer time reached, reload data
      if (remaining == "00:00:00") {
        _loadPrayerData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('الصلاة والقبلة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              if (_prayerTimes.isEmpty)
                const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)))
              else
                _buildPrayerGrid(_prayerTimes),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'اتجاه القبلة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: QiblaCompass()),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    // Using intl to format date in Arabic. 
    // Assumes initializeDateFormatting('ar') was called in main.dart
    final gregorianDate = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);
    
    // Real dates as requested - using placeholder for Hijri to match React design
    const hijriDate = "٢ صفر ١٤٤٨"; 

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF006C35),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006C35).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gregorianDate,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hijriDate,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  '📍 الرياض ▾',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الصلاة القادمة',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _nextPrayerName,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _remainingTime,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.w500,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const Text('🕌', style: TextStyle(fontSize: 48)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerGrid(List<PrayerTime> prayerTimes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: prayerTimes.length,
      itemBuilder: (context, index) {
        final prayer = prayerTimes[index];
        final isNext = prayer.isNext;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isNext ? const Color(0xFF006C35) : (isDark ? const Color(0xFF30363D) : const Color(0xFFF1F1F1)),
              width: isNext ? 2 : 1,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prayer.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(
                      prayer.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      prayer.time,
                      style: TextStyle(
                        fontSize: 13,
                        color: isNext ? const Color(0xFF006C35) : const Color(0xFF6B7280),
                        fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (isNext)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006C35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'التالية',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
