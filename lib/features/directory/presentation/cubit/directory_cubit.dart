import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/directory_repository_impl.dart';
import 'directory_state.dart';

class DirectoryCubit extends Cubit<DirectoryState> {
  final DirectoryRepositoryImpl _repository = DirectoryRepositoryImpl();
  StreamSubscription? _subscription;

  DirectoryCubit() : super(DirectoryInitial());

  void init() {
    searchContacts("");
  }

  void searchContacts(String query) {
    emit(DirectoryLoading());
    _subscription?.cancel();
    _subscription = _repository.getContactsStream(query: query).listen(
      (contacts) {
        emit(DirectoryLoaded(contacts: contacts, searchQuery: query));
      },
      onError: (e) => emit(DirectoryError(e.toString())),
    );
  }

  Future<void> syncUserContacts() async {
    try {
      await _repository.syncLocalContacts();
    } catch (e) {
      // Silently fail or log
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
