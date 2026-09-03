import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'خبر عاجل: صدور أمر ملكي جديد',
        'body': 'تفاصيل القرارات الملكية الجديدة التي تم إعلانها مساء اليوم...',
        'time': 'منذ 10 دقائق',
        'icon': Icons.notifications_active,
        'color': Colors.red,
        'isRead': false,
      },
      {
        'title': 'مباراة الليلة: الهلال ضد النصر',
        'body': 'استعد لمتابعة ديربي الرياض المثير ضمن منافسات دوري روشن السعودي...',
        'time': 'منذ ساعة',
        'icon': Icons.sports_soccer,
        'color': Colors.blue,
        'isRead': true,
      },
      {
        'title': 'تحديث التطبيق',
        'body': 'تتوفر ميزات جديدة في الإصدار الجديد من تطبيق أخبار السعودية...',
        'time': 'منذ 3 ساعات',
        'icon': Icons.system_update,
        'color': Colors.green,
        'isRead': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              // Mark all as read
            },
          ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return _buildNotificationItem(context, item, isDark);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> item, bool isDark) {
    final saudiGreen = const Color(0xFF006C35);
    final isRead = item['isRead'] as bool;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isRead 
          ? (isDark ? const Color(0xFF161B22) : Colors.white)
          : (isDark ? saudiGreen.withValues(alpha:0.1) : const Color(0xFFF0FDF4)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead 
            ? (isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6))
            : (isDark ? saudiGreen.withValues(alpha:0.3) : const Color(0xFFDCFCE7)),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['icon'] is IconData ? "🔔" : item['icon'], // Using emoji if possible
            style: const TextStyle(fontSize: 24),
          ),
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
                        item['title'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                    ),
                    Text(
                      item['time'],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['body'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                  maxLines: 2,
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
            'لا توجد إشعارات',
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
