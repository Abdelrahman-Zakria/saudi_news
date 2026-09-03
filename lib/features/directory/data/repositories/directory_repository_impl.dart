import '../../domain/entities/directory_item.dart';
import '../../domain/repositories/directory_repository.dart';

class DirectoryRepositoryImpl implements DirectoryRepository {
  @override
  Future<List<DirectoryItem>> getDirectoryItems() async {
    // Simulated delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      DirectoryItem(
        id: 1,
        name: "مستشفى الملك فيصل التخصصي",
        category: "مستشفيات",
        phone: "920012220",
        city: "الرياض",
        address: "حي الملك فهد، الرياض",
        rating: 4.8,
      ),
      DirectoryItem(
        id: 2,
        name: "وزارة الداخلية",
        category: "حكومي",
        phone: "920004444",
        city: "الرياض",
        address: "طريق الملك عبدالعزيز، الرياض",
        rating: 4.2,
      ),
      DirectoryItem(
        id: 3,
        name: "مطعم البيك",
        category: "مطاعم",
        phone: "920002626",
        city: "جدة",
        address: "طريق الملك عبدالله، جدة",
        rating: 4.7,
      ),
      DirectoryItem(
        id: 4,
        name: "شركة STC للاتصالات",
        category: "اتصالات",
        phone: "900",
        city: "الرياض",
        address: "طريق الملك فهد، الرياض",
        rating: 3.9,
      ),
      DirectoryItem(
        id: 5,
        name: "طيران ناس",
        category: "طيران",
        phone: "920002288",
        city: "جدة",
        address: "مطار الملك عبدالعزيز، جدة",
        rating: 4.1,
      ),
      DirectoryItem(
        id: 6,
        name: "المستشفى السعودي الألماني",
        category: "مستشفيات",
        phone: "920001111",
        city: "جدة",
        address: "شارع التحلية، جدة",
        rating: 4.5,
      ),
      DirectoryItem(
        id: 7,
        name: "هيئة الزكاة والضريبة",
        category: "حكومي",
        phone: "19993",
        city: "الرياض",
        address: "حي العقيق، الرياض",
        rating: 4.0,
      ),
      DirectoryItem(
        id: 8,
        name: "مطعم نايف للمندي",
        category: "مطاعم",
        phone: "0112345678",
        city: "الرياض",
        address: "حي الملز، الرياض",
        rating: 4.6,
      ),
    ];
  }
}
