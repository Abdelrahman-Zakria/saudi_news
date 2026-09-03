class PrayerTime {
  final String name;
  final String time;
  final String icon;
  final bool isNext;

  PrayerTime({
    required this.name,
    required this.time,
    required this.icon,
    this.isNext = false,
  });
}
