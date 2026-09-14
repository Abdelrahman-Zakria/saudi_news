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
    final List<DirectoryContact> localContacts = state.localContacts;

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        _subscription?.cancel();
        emit(DirectoryLoaded(localContacts: localContacts, searchQuery: "", isSearchView: false));
        return;
      }

      emit(DirectoryLoading(searchQuery: query, localContacts: localContacts, isSearchView: true));

      _subscription?.cancel();
      _subscription = _repository.searchFirestoreContacts(query: query).listen(
        (results) {
          emit(DirectoryLoaded(
            localContacts: localContacts,
            searchResults: results,
            searchQuery: query,
            isSearchView: true,
          ));
        },
        onError: (e) => emit(DirectoryError(e.toString(), localContacts: localContacts, isSearchView: true)),
      );
    });
  }

  Future<List<DirectoryContact>> performLookup(String number) async {
    emit(DirectoryLoading(
      searchQuery: number, 
      localContacts: state.localContacts, 
      isSearchView: true
    ));
    
    try {
      final results = await _repository.lookupNumber(number);
      
      emit(DirectoryLoaded(
        localContacts: state.localContacts,
        searchResults: results,
        searchQuery: number,
        isSearchView: true,
      ));
      
      return results;
    } catch (e) {
      emit(DirectoryError(e.toString(), 
        localContacts: state.localContacts, 
        isSearchView: true
      ));
      return [];
    }
  }

  Future<void> syncUserContacts() async {
    try {
      await _repository.syncLocalContacts();
      await init(); 
    } catch (e) {}
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _debounce?.cancel();
    return super.close();
  }
}
