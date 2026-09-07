part of 'notifications_cubit.dart';

class NotificationsState {
  final List<dynamic> history;
  final bool isLoading;

  const NotificationsState({
    required this.history,
    this.isLoading = false,
  });

  NotificationsState copyWith({
    List<dynamic>? history,
    bool? isLoading,
  }) {
    return NotificationsState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
