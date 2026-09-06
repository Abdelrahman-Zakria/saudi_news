import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/directory_repository_impl.dart';
import 'directory_state.dart';

class DirectoryCubit extends Cubit<DirectoryState> {
  final DirectoryRepositoryImpl _repository = DirectoryRepositoryImpl();
  StreamSubscription? _subscription;
  Timer? _debounce;

  DirectoryCubit() : super(DirectoryInitial());

  void init() {
    _startSubscription(limit: 20);
  }

  void _startSubscription({required int limit, String query = "", String category = "الكل"}) {
    emit(DirectoryLoading(searchQuery: query, activeCategory: category));

    _subscription?.cancel();
    _subscription = _repository.getContactsStream(query: query, category: category, limit: limit).listen(
      (contacts) {
        emit(DirectoryLoaded(
          contacts: contacts, 
          searchQuery: query,
          activeCategory: category,
          currentLimit: limit,
          hasMore: contacts.length >= limit,
        ));
      },
      onError: (e) => emit(DirectoryError(
        e.toString(),
        searchQuery: query,
        activeCategory: category,
      )),
    );
  }

  void searchContacts(String query) {
    final category = state.activeCategory;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _startSubscription(limit: 20, query: query, category: category);
    });
  }

  void changeCategory(String category) {
    final query = state.searchQuery;
    final String nextCategory = (state.activeCategory == category) ? "الكل" : category;
    _startSubscription(limit: 20, query: query, category: nextCategory);
  }

  void loadMore() {
    if (state is DirectoryLoaded) {
      final s = state as DirectoryLoaded;
      if (s.hasMore) {
        _startSubscription(
          limit: s.currentLimit + 20, 
          query: s.searchQuery, 
          category: s.activeCategory
        );
      }
    }
  }

  Future<void> syncUserContacts() async {
    try {
      await _repository.syncLocalContacts();
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _debounce?.cancel();
    return super.close();
  }
}
