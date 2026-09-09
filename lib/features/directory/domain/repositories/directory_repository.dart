import '../entities/directory_item.dart';

abstract class DirectoryRepository {
  Future<List<DirectoryItem>> getDirectoryItems();
}
