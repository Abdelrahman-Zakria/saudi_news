class TeamMapper {
  static const Map<String, String> _nameToArabic = {
    'Al Hilal': 'الهلال',
    'Al Nassr': 'النصر',
    'Al Ittihad': 'الاتحاد',
    'Al Ahli': 'الأهلي',
    'Al Shabab': 'الشباب',
    'Al Ettifaq': 'الاتفاق',
    'Al Taawoun': 'التعاون',
    'Al Fateh': 'الفتح',
    'Al Fayha': 'الفيحاء',
    'Al Wehda': 'الوحدة',
    'Damac': 'ضمك',
    'Abha': 'أبها',
    'Al Hazem': 'الحزم',
    'Al Riyadh': 'الرياض',
    'Al Khaleej': 'الخليج',
    'Al Tai': 'الطائي',
    'Al Akhdoud': 'الأخدود',
    'Al Qadsiah': 'القادسية',
    'Neom SC': 'نيوم',
    'Al Kholood': 'الخلود',
    'Al Diriyah': 'الدرعية',
    'Al Faisaly': 'الفيصلي',
    'Al Orobah': 'العروبة',
  };

  static String toArabic(String englishName) {
    // Try exact match or contains logic for common variations
    for (var entry in _nameToArabic.entries) {
      if (englishName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return englishName;
  }
}
