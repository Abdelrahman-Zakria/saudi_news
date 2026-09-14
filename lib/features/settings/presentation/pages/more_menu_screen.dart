import 'package:flutter/material.dart';
import 'package:saudi_news/features/news/presentation/pages/technology_news_screen.dart';
import 'package:saudi_news/features/prayer/presentation/pages/prayer_screen.dart';
import 'favorites_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import '../../../../core/services/iap_service.dart';

class MoreMenuScreen extends StatelessWidget {
  final Function(int)? onTabChange;

  const MoreMenuScreen({
    super.key,
    this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<bool>(
      stream: IAPService().proStatusStream,
      initialData: IAPService().isPro,
      builder: (context, snapshot) {
        final isPro = snapshot.data ?? false;

        final List<Map<String, dynamic>> menuItems = [
          {
            'title': 'التكنولوجيا',
            'icon': '💻',
            'description': 'أحدث أخبار التقنية والأجهزة',
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TechnologyNewsScreen()),
              );
            },
          },
          {
            'title': 'دليل الهاتف السعودي',
            'icon': '📞',
            'description': 'البحث عن الأرقام والجهات',
            'onTap': () {
              if (onTabChange != null) {
                onTabChange!(1);
              }
            },
          },
          {
            'title': 'مواقيت الصلاة والقبلة',
            'icon': '🕌',
            'description': 'أوقات الصلاة واتجاه القبلة',
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrayerScreen()),
              );
            },
          },
          if (!isPro)
            {
              'title': 'إزالة الإعلانات',
              'icon': '🚫',
              'description': 'استمتع بتجربة خالية من الإعلانات مقابل ٣ دولارات',
              'isSpecial': true,
              'onTap': () => _showRemoveAdsDialog(context),
            },
          {
            'title': 'المفضلة',
            'icon': '♥',
            'description': 'الأخبار التي قمت بحفظها',
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          },
          {
            'title': 'الإشعارات',
            'icon': '🔔',
            'description': 'تنبيهات الأخبار العاجلة',
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          },
          {
            'title': 'الإعدادات',
            'icon': '⚙️',
            'description': 'تخصيص التطبيق والمظهر',
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          },
        ];

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: AppBar(
            title: const Text('المزيد', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: menuItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuButton(context, item, isDark);
              },
            ),
          ),
        );
      },
    );
  }

  void _showRemoveAdsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إزالة الإعلانات للأبد',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'استمتع بتجربة تصفح أسرع وأكثر سلاسة بدون أي إعلانات مزعجة داخل التطبيق.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    IAPService().buyRemoveAds();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006C35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'شراء الآن - ٣ دولار',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  IAPService().restorePurchases();
                },
                child: const Text('استعادة المشتروات'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(BuildContext context, Map<String, dynamic> item, bool isDark) {
    final theme = Theme.of(context);
    final bool isSpecial = item['isSpecial'] ?? false;
    
    return InkWell(
      onTap: item['onTap'],
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSpecial 
              ? const Color(0xFF006C35).withValues(alpha:0.5) 
              : (isDark ? const Color(0xFF30363D) : const Color(0xFFF1F1F1)),
            width: isSpecial ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isSpecial ? const Color(0xFF006C35) : theme.colorScheme.primary).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item['icon'],
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSpecial ? const Color(0xFF006C35) : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
