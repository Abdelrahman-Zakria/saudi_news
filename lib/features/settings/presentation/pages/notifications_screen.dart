import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import '../cubit/notifications_cubit.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().loadHistory();
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 60) {
        return "منذ ${diff.inMinutes} دقيقة";
      } else if (diff.inHours < 24) {
        return "منذ ${diff.inHours} ساعة";
      } else {
        return intl.DateFormat('yyyy/MM/dd').format(dt);
      }
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                if (state.history.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: "تحديد الكل كمقروء",
                  onPressed: () => context.read<NotificationsCubit>().markAllAsRead(),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
              }

              if (state.history.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  final item = state.history[index];
                  return _buildNotificationItem(context, item, isDark);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> item, bool isDark) {
    final saudiGreen = const Color(0xFF006C35);
    final bool isRead = item['isRead'] ?? true;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isRead 
          ? (isDark ? const Color(0xFF161B22) : Colors.white)
          : (isDark ? saudiGreen.withOpacity(0.1) : const Color(0xFFF0FDF4)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead 
            ? (isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6))
            : (isDark ? saudiGreen.withOpacity(0.3) : const Color(0xFFDCFCE7)),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🔔", style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['title'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                    ),
                    if (item['timestamp'] != null)
                      Text(
                        _formatTimestamp(item['timestamp']),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['body'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4, right: 8),
              decoration: BoxDecoration(
                color: saudiGreen,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Opacity(
            opacity: 0.3,
            child: Text("🔔", style: TextStyle(fontSize: 64)),
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد إشعارات حالياً',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
