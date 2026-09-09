import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saudi_news/features/directory/domain/entities/directory_contact.dart';
import '../../data/repositories/directory_repository_impl.dart';
import 'directory_state.dart';

class DirectoryCubit extends Cubit<DirectoryState> {
  final DirectoryRepositoryImpl _repository = DirectoryRepositoryImpl();
  StreamSubscription? _subscription;
  Timer? _debounce;

  DirectoryCubit() : super(DirectoryInitial());

  Future<void> init() async {
    emit(DirectoryLoading());
    try {
      final localContacts = await _repository.getLocalContacts();
      emit(DirectoryLoaded(localContacts: localContacts));
    } catch (e) {
      emit(DirectoryError(e.toString()));
    }
  }

  void searchFirestore(String query) {
    final String currentCategory = state.activeCategory;
    final List<DirectoryContact> localContacts = state.localContacts;

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty && currentCategory == "الكل") {
        _subscription?.cancel();
        emit(DirectoryLoaded(localContacts: localContacts, searchQuery: "", activeCategory: "الكل", isSearchView: false));
        return;
      }

      emit(DirectoryLoading(searchQuery: query, activeCategory: currentCategory, localContacts: localContacts, isSearchView: true));

      _subscription?.cancel();
      _subscription = _repository.searchFirestoreContacts(query: query, category: currentCategory).listen(
        (results) {
          emit(DirectoryLoaded(
            localContacts: localContacts,
            searchResults: results,
            searchQuery: query,
            activeCategory: currentCategory,
            isSearchView: true,
            hasMore: results.length >= 20,
          ));
        },
        onError: (e) => emit(DirectoryError(e.toString(), localContacts: localContacts, isSearchView: true)),
      );
    });
  }

  void changeCategory(String category) {
    final query = state.searchQuery;
    final nextCategory = (state.activeCategory == category) ? "الكل" : category;
    _performSearch(query, nextCategory);
  }

  void _performSearch(String query, String category) {
    final localContacts = state.localContacts;
    
    if (query.isEmpty && category == "الكل") {
       _subscription?.cancel();
       emit(DirectoryLoaded(localContacts: localContacts, searchQuery: "", activeCategory: "الكل", isSearchView: false));
       return;
    }

    emit(DirectoryLoading(searchQuery: query, activeCategory: category, localContacts: localContacts, isSearchView: true));
    _subscription?.cancel();
    _subscription = _repository.searchFirestoreContacts(query: query, category: category).listen(
      (results) {
        emit(DirectoryLoaded(
          localContacts: localContacts,
          searchResults: results,
          searchQuery: query,
          activeCategory: category,
          isSearchView: true,
          hasMore: results.length >= 20,
        ));
      },
      onError: (e) => emit(DirectoryError(e.toString(), localContacts: localContacts, isSearchView: true)),
    );
  }

  Future<void> syncUserContacts() async {
    try {
      await _repository.syncLocalContacts();
      await init(); // Reload local list after sync
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
