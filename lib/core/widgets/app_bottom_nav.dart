import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saudiGreen = const Color(0xFF006C35);

    final tabs = [
      {'icon': '🏠', 'label': 'الرئيسية'},
      {'icon': '📞', 'label': 'دليل الهاتف'},
      {'icon': '⚽', 'label': 'دوري روشن'},
      {'icon': '💼', 'label': 'الوظائف'},
      {'icon': '☰', 'label': 'المزيد'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
          ),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = currentIndex == index;
          final tab = tabs[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        tab['icon']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tab['label']!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? saudiGreen
                            : (isDark ? Colors.grey[500] : Colors.grey[400]),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: saudiGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
