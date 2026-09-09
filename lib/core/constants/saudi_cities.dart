class CityModel {
  final String name;
  final double latitude;
  final double longitude;

  const CityModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

const List<CityModel> saudiCities = [
  CityModel(name: 'الرياض', latitude: 24.7136, longitude: 46.6753),
  CityModel(name: 'جدة', latitude: 21.4858, longitude: 39.1925),
  CityModel(name: 'مكة المكرمة', latitude: 21.4225, longitude: 39.8262),
  CityModel(name: 'المدينة المنورة', latitude: 24.5247, longitude: 39.5692),
  CityModel(name: 'الدمام', latitude: 26.4207, longitude: 50.0888),
  CityModel(name: 'الطائف', latitude: 21.2854, longitude: 40.4258),
  CityModel(name: 'تبوك', latitude: 28.3835, longitude: 36.5662),
  CityModel(name: 'بريدة', latitude: 26.3260, longitude: 43.9750),
  CityModel(name: 'خميس مشيط', latitude: 18.3064, longitude: 42.7350),
  CityModel(name: 'الهفوف', latitude: 25.3781, longitude: 49.5847),
  CityModel(name: 'حائل', latitude: 27.5219, longitude: 41.6961),
  CityModel(name: 'نجران', latitude: 17.4933, longitude: 44.1277),
  CityModel(name: 'أبها', latitude: 18.2171, longitude: 42.5053),
  CityModel(name: 'جازان', latitude: 16.8894, longitude: 42.5706),
  CityModel(name: 'الخبر', latitude: 26.2828, longitude: 50.2106),
  CityModel(name: 'الجبيل', latitude: 27.0117, longitude: 49.6583),
  CityModel(name: 'حفر الباطن', latitude: 28.4328, longitude: 45.9708),
  CityModel(name: 'الخرج', latitude: 24.1504, longitude: 47.3117),
  CityModel(name: 'عرعر', latitude: 30.9753, longitude: 41.0381),
  CityModel(name: 'سكاكا', latitude: 29.9697, longitude: 40.2064),
];
