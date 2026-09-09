import 'package:saudi_news/features/directory/domain/entities/directory_contact.dart';

abstract class DirectoryState {
  final String searchQuery;
  final String activeCategory;
  final List<DirectoryContact> localContacts;
  final bool isSearchView;

  DirectoryState({
    this.searchQuery = "", 
    this.activeCategory = "الكل",
    this.localContacts = const [],
    this.isSearchView = false,
  });
}

class DirectoryInitial extends DirectoryState {}

class DirectoryLoading extends DirectoryState {
  DirectoryLoading({super.searchQuery, super.activeCategory, super.localContacts, super.isSearchView});
}

class DirectoryLoaded extends DirectoryState {
  final List<DirectoryContact> searchResults;
  final bool hasMore;

  DirectoryLoaded({
    required super.localContacts,
    this.searchResults = const [], 
    super.searchQuery = "",
    super.activeCategory = "الكل",
    this.hasMore = true,
    super.isSearchView = false,
  });

  DirectoryLoaded copyWith({
    List<DirectoryContact>? localContacts,
    List<DirectoryContact>? searchResults,
    String? searchQuery,
    String? activeCategory,
    bool? hasMore,
    bool? isSearchView,
  }) {
    return DirectoryLoaded(
      localContacts: localContacts ?? this.localContacts,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      activeCategory: activeCategory ?? this.activeCategory,
      hasMore: hasMore ?? this.hasMore,
      isSearchView: isSearchView ?? this.isSearchView,
    );
  }
}

class DirectoryError extends DirectoryState {
  final String message;
  DirectoryError(this.message, {super.searchQuery, super.activeCategory, super.localContacts, super.isSearchView});
}
