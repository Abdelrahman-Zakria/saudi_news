import '../../domain/entities/directory_contact.dart';

abstract class DirectoryState {}

class DirectoryInitial extends DirectoryState {}

class DirectoryLoading extends DirectoryState {}

class DirectoryLoaded extends DirectoryState {
  final List<DirectoryContact> contacts;
  final String searchQuery;

  DirectoryLoaded({required this.contacts, this.searchQuery = ""});
}

class DirectoryError extends DirectoryState {
  final String message;
  DirectoryError(this.message);
}
