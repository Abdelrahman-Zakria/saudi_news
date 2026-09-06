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
    final navBgColor = const Color(0xFF006559);
    final activeColor = Colors.white;
    final inactiveColor = Colors.white.withOpacity(0.6);

    final tabs = [
      {'icon': '🏠', 'label': 'الرئيسية'},
      {'icon': '📞', 'label': 'دليل الهاتف'},
      {'icon': '⚽', 'label': 'دوري روشن'},
      {'icon': '💼', 'label': 'الوظائف'},
      {'icon': '☰', 'label': 'المزيد'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: navBgColor,
        border: Border(
          top: BorderSide(
            color: Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = currentIndex == index;
          final tab = tabs[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
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
                  const SizedBox(height: 4),
                  Text(
                    tab['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
