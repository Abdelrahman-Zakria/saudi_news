import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState(history: []));

  Future<void> loadHistory() async {
    emit(state.copyWith(isLoading: true));
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('notifications_history');
    if (data != null) {
      final List history = jsonDecode(data);
      emit(state.copyWith(history: history, isLoading: false));
    } else {
      emit(state.copyWith(history: [], isLoading: false));
    }
  }

  Future<void> markAsRead(String timestamp) async {
    final updated = state.history.map((e) {
      if (e['timestamp'] == timestamp) {
        e['isRead'] = true;
      }
      return e;
    }).toList();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications_history', jsonEncode(updated));
    emit(state.copyWith(history: updated));
  }

  Future<void> markAllAsRead() async {
    final updated = state.history.map((e) {
      e['isRead'] = true;
      return e;
    }).toList();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications_history', jsonEncode(updated));
    emit(state.copyWith(history: updated));
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications_history');
    emit(state.copyWith(history: []));
  }
}
