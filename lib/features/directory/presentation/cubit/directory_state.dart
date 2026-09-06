import '../../domain/entities/directory_contact.dart';

abstract class DirectoryState {
  final String searchQuery;
  final String activeCategory;

  DirectoryState({this.searchQuery = "", this.activeCategory = "الكل"});
}

class DirectoryInitial extends DirectoryState {}

class DirectoryLoading extends DirectoryState {
  DirectoryLoading({super.searchQuery, super.activeCategory});
}

class DirectoryLoaded extends DirectoryState {
  final List<DirectoryContact> contacts;
  final int currentLimit;
  final bool hasMore;

  DirectoryLoaded({
    required this.contacts, 
    super.searchQuery = "",
    super.activeCategory = "الكل",
    this.currentLimit = 20,
    this.hasMore = true,
  });

  DirectoryLoaded copyWith({
    List<DirectoryContact>? contacts,
    String? searchQuery,
    String? activeCategory,
    int? currentLimit,
    bool? hasMore,
  }) {
    return DirectoryLoaded(
      contacts: contacts ?? this.contacts,
      searchQuery: searchQuery ?? this.searchQuery,
      activeCategory: activeCategory ?? this.activeCategory,
      currentLimit: currentLimit ?? this.currentLimit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class DirectoryError extends DirectoryState {
  final String message;
  DirectoryError(this.message, {super.searchQuery, super.activeCategory});
}
